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
          
          parse_response(response.dig("choices", 0, "message", "content"))
        end
        redirect_to result_recipes_path(@recipe)
      rescue Faraday::TooManyRequestsError => e
        retries += 1
        if retries <= 3
          sleep_time = 2 ** retries
          sleep(sleep_time)
          retry
        else
          flash[:error] = "APIリクエスト制限に達しました。しばらく待ってから再試行してください。"
          redirect_to recipe_conditions_new_path
        end
      rescue => e
        flash[:error] = "レシピの生成中にエラーが発生しました。"
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
    "以下の条件でレシピを考えてください：
     - カテゴリー: #{category}
     - 調理時間: #{cooking_time}
     - 材料: #{ingredients}
     
     レシピは以下の形式で返してください：
     1. レシピ名
     2. 材料リスト（分量も含む）
     3. 調理手順（番号付きのステップ）"
  end

  def parse_response(content)
    {
      name: content.match(/1\.\s*(.+)/)[1],
      cooking_time: params[:cooking_time],
      category: params[:category],
      ingredients: content.match(/2\.\s*(.+?)3\./m)[1].strip,
      instructions: content.match(/3\.\s*(.+)/m)[1].strip
    }
  rescue
    nil
  end

  def valid_form_input?
    params[:category].present? &&
    params[:cooking_time].present? &&
    params[:ingredients].present?
  end
end
