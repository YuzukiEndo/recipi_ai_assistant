require 'line/bot'
require 'openai'

class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          handle_text_message(event)
        end
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def handle_text_message(event)
    user_id = event['source']['userId']
    text = event.message['text']

    case get_user_state(user_id)
    when 'initial'
      if text == 'レシピ生成'
        ask_cooking_time(event['replyToken'])
        set_user_state(user_id, 'waiting_for_cooking_time')
      else
        client.reply_message(event['replyToken'], { type: 'text', text: 'レシピを生成するには「レシピ生成」と入力してください。' })
      end
    when 'waiting_for_cooking_time'
      if ['短時間', '普通', '長時間'].include?(text)
        save_user_input(user_id, 'cooking_time', text)
        ask_category(event['replyToken'])
        set_user_state(user_id, 'waiting_for_category')
      else
        client.reply_message(event['replyToken'], { type: 'text', text: '無効な調理時間です。短時間、普通、長時間から選んでください。' })
      end
    when 'waiting_for_category'
      if ['和風', '洋風', '中華風'].include?(text)
        save_user_input(user_id, 'category', text)
        ask_ingredients(event['replyToken'])
        set_user_state(user_id, 'waiting_for_ingredients')
      else
        client.reply_message(event['replyToken'], { type: 'text', text: '無効なカテゴリーです。和風、洋風、中華風から選んでください。' })
      end
    when 'waiting_for_ingredients'
      save_user_input(user_id, 'ingredients', text)
      ask_confirmation(event['replyToken'])
      set_user_state(user_id, 'waiting_for_confirmation')
    when 'waiting_for_confirmation'
      if text == 'レシピ生成'
        generate_and_send_recipe(event['replyToken'], user_id)
        set_user_state(user_id, 'initial')
      elsif text == '条件変更'
        ask_cooking_time(event['replyToken'])
        set_user_state(user_id, 'waiting_for_cooking_time')
      else
        client.reply_message(event['replyToken'], { type: 'text', text: '「レシピ生成」または「条件変更」と入力してください。' })
      end
    end
  end

  def ask_cooking_time(reply_token)
    message = { type: 'text', text: '調理時間を選択してください（短時間、普通、長時間）' }
    client.reply_message(reply_token, message)
  end

  def ask_category(reply_token)
    message = { type: 'text', text: 'カテゴリーを選択してください（和風、洋風、中華風）' }
    client.reply_message(reply_token, message)
  end

  def ask_ingredients(reply_token)
    message = { type: 'text', text: '食材を入力してください' }
    client.reply_message(reply_token, message)
  end

  def ask_confirmation(reply_token)
    message = { type: 'text', text: '条件を変更する場合は「条件変更」、レシピを生成する場合は「レシピ生成」と入力してください' }
    client.reply_message(reply_token, message)
  end

  def generate_and_send_recipe(reply_token, user_id)
    cooking_time = get_user_input(user_id, 'cooking_time')
    category = get_user_input(user_id, 'category')
    ingredients = get_user_input(user_id, 'ingredients')

    unless check_rate_limit(user_id)
      client.reply_message(reply_token, { type: 'text', text: 'レシピ生成回数の制限に達しました。1時間後に再試行してください。' })
      return
    end

    recipe = generate_recipe(category, cooking_time, ingredients)
    client.reply_message(reply_token, { type: 'text', text: format_recipe_for_line(recipe) })
  end

  def get_user_state(user_id)
    Rails.cache.read("#{user_id}_state") || 'initial'
  end

  def set_user_state(user_id, state)
    Rails.cache.write("#{user_id}_state", state, expires_in: 1.hour)
  end

  def save_user_input(user_id, key, value)
    Rails.cache.write("#{user_id}_#{key}", value, expires_in: 1.hour)
  end

  def get_user_input(user_id, key)
    Rails.cache.read("#{user_id}_#{key}")
  end

  def check_rate_limit(user_id)
    key = "rate_limit_#{user_id}"
    count = Rails.cache.read(key) || 0
    count += 1
    Rails.cache.write(key, count, expires_in: 1.hour)
    
    count <= 20
  end

  def generate_recipe(category, cooking_time, ingredients)
    prompt = generate_prompt(category, cooking_time, ingredients)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7,
      }
    )
    parse_response(response.dig("choices", 0, "message", "content"))
  rescue => e
    Rails.logger.error("OpenAI API error: #{e.message}")
    nil
  end

  def generate_prompt(category, cooking_time, ingredients)
    <<~PROMPT
      You are an excellent chef. Please create a specific and executable recipe based on the following conditions:

      # 以下の条件に基づいてレシピを作成してください
      Create a recipe based on the following conditions:
        - Category: #{category}
        - Cooking time: #{cooking_time}
        - Main ingredients: #{ingredients}

      Important notes:

      1. Recipe Basis:
        # 既存の料理をベースにしつつ、創造的なアレンジも可能です
        - Base the recipe on existing dishes, but feel free to be creative 
        # 全ての出力は1人分とすること
        - All output must be for a single serving.
        # なるべく栄養バランスの取れているレシピを生成してください。
        - Generate a recipe with a well-balanced nutritional profile as much as possible.

      2. Ingredient Handling:
        # 入力に食材以外のものが含まれている場合は完全に無視すること
        - Completely ignore any non-food items in the input ingredients.
        # 食べられないもの、危険なもの、人名は絶対に材料として使用しないこと
        - Never use inedible items, dangerous substances, or people's names as ingredients.
        # 入力されていない必要な材料も追加すること
        - Add any necessary ingredients that were not included in the input.

      3. Output Requirements:
        # 全ての情報は日本語のみで提供すること
        - Provide all information in Japanese only.
        # レシピ名、材料リスト、調理手順、栄養情報を含めること
        - Include recipe name, ingredients list, cooking instructions, and nutritional information.
        # 調理手順は丁寧かつ明確に記載してください。
        - Provide cooking instructions that are detailed, clear, and easy to follow

      4. Safety and Appropriateness:
        # 全ての材料と手順が安全で消費に適していることを確認すること
        - Ensure all ingredients and steps are safe and suitable for consumption.

      If the ingredients are appropriate, please create a recipe in Japanese using the following format:

      1. 
      [Write only the recipe name in one line]

      2.
      - [Ingredient 1]: [Amount]
      - [Ingredient 2]: [Amount]
      ...

      3.
      1. [Step 1]
      2. [Step 2]
      ...

      4.
      - カロリー: [数値] kcal
      - タンパク質: [数値] g
      - 脂質: [数値] g
      - 炭水化物: [数値] g
      - 食物繊維: [数値] g

    PROMPT
  end

  def parse_response(content)
    sections = content.split(/\n\n\d+\.\s+/)
    {
      name: sections[0]&.split("\n")&.first&.gsub(/^\d+\.\s*/, '')&.strip,
      ingredients: sections[1]&.strip,
      instructions: sections[2]&.strip,
      nutrition: sections[3]&.strip
    }
  rescue => e
    nil
  end

  def format_recipe_for_line(recipe)
    return "レシピの生成に失敗しました。もう一度お試しください。" if recipe.nil?

    text = <<~TEXT
      レシピ名: #{recipe[:name]}

      材料:
      #{recipe[:ingredients]}

      調理手順:
      #{recipe[:instructions]}

      栄養価情報:
      #{recipe[:nutrition]}
    TEXT

    if text.length > 5000 
      text = text[0...4997] + "..."
    end

    text
  end
end
