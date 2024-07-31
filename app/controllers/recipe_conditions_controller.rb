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
        # 既存のコード
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
      あなたは優秀な料理人です。以下の条件に基づいて、具体的で実行可能なレシピを作成してください：

      条件：
      - カテゴリー: #{category}
      - 調理時間: #{cooking_time}
      - 主な材料: #{ingredients}

      以下の形式で、日本語でレシピを作成してください：

      1. 料理名
      [ここに料理名のみを1行で記入]

      2. 材料リスト（1人前）
      - [材料1]: [分量]
      - [材料2]: [分量]
      ...

      3. 調理手順
      1. [手順1]
      2. [手順2]
      ...

      注意事項：
      - 料理名は必ず記載し、既存の料理名を使用してください。
      - 材料リストは1人前の分量を明確に記載してください。
      - 調理手順は簡潔かつ明確に、番号付きで記載してください。
      - 指定された材料を必ず使用し、存在しない材料は無視してください。
      - 各セクションの間に空行を入れてください。
      このフォーマットに厳密に従ってレシピを作成してください。
    PROMPT
  end

  def parse_response(content)
    sections = content.split(/\n\n\d+\.\s+/)
    name = sections[0]&.split("\n")&.first&.gsub(/^\d+\.\s*/, '')&.strip
    {
      name: name,
      cooking_time: params[:cooking_time],
      category: params[:category],
      ingredients: sections[1]&.strip,
      instructions: sections[2]&.strip
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
