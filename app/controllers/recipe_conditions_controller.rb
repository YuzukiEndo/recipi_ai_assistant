require 'openai'

class RecipeConditionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :check_rate_limit, only: [:create]

  def new
    @categories = ['和食', '洋食', '中華']
    @cooking_times = ['短め', '普通', '長め']
    @ingredients = Ingredient.all
  end

  def create
    if valid_form_input?
      retries = 0
      begin
        cache_key = "recipe_#{params[:category]}_#{params[:cooking_time]}_#{params[:ingredients]}"
        @recipe = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          client = OpenAI::Client.new
          prompt = generate_prompt(params[:category], params[:cooking_time], params[:ingredients])
          
          response = client.chat(
            parameters: {
              model: "gpt-3.5-turbo",
              messages: [{ role: "user", content: prompt }],
              temperature: 0.7,
            })
          Rails.logger.debug "API Response: #{response.inspect}"
          parsed_recipe = parse_response(response.dig("choices", 0, "message", "content"))
          Rails.logger.debug "Parsed Recipe: #{parsed_recipe.inspect}"
          parsed_recipe
        end
        if @recipe.nil? || @recipe.empty?
          raise "Failed to generate recipe"
        end
        redirect_to result_recipes_path(@recipe)
      rescue Faraday::TooManyRequestsError => e
      rescue => e
        Rails.logger.error "Error generating recipe: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        flash[:error] = "レシピの生成中にエラーが発生しました。詳細: #{e.message}"
        redirect_to recipe_conditions_new_path
      end
    else
      flash.now[:danger] = '不適切な入力データです。全ての項目を入力してください。'
      @categories = ['和食', '洋食', '中華']
      @cooking_times = ['短め', '普通', '長め']
      @ingredients = Ingredient.all
      render :new
    end
  end

  private

  def check_rate_limit
    key = "rate_limit_#{request.remote_ip}"
    count = Rails.cache.read(key) || 0
    count += 1
    Rails.cache.write(key, count, expires_in: 1.hour)
    
    if count > 5
      flash[:error] = "リクエスト回数の制限に達しました。しばらく待ってから再試行してください。"
      redirect_to recipe_conditions_new_path
    end
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
          # 既存の有名な料理をベースにレシピを生成すること
        - Base the recipe on well-known, existing dishes.
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
          # 必要に応じてレシピを調整し、安全性と料理の基準を維持すること
        - Adapt the recipe if necessary to maintain safety and culinary standards.

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
      cooking_time: params[:cooking_time],
      category: params[:category],
      ingredients: sections[1]&.strip,
      instructions: sections[2]&.strip,
      nutrition: sections[3]&.strip
    }
  rescue => e
    nil
  end

  def valid_form_input?
    params[:category].present? &&
    params[:cooking_time].present? &&
    params[:ingredients].present?
  end
end
