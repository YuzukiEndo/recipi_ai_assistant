class RecipesController < ApplicationController
  skip_before_action :require_login, only: [:result, :show]

  def result
    @recipe = params.permit(:name, :cooking_time, :category, :ingredients, :instructions, :nutrition).to_h.symbolize_keys
  
    if @recipe[:name].present?
      begin
        @recipe_record = Recipe.create!(
          name: @recipe[:name],
          cooking_time_minutes: @recipe[:cooking_time],
          category: @recipe[:category],
          ingredients: @recipe[:ingredients].presence || "材料情報なし",
          instructions: @recipe[:instructions].presence || "調理手順情報なし",
          calories: extract_nutrition_value(@recipe[:nutrition], 'カロリー'),
          protein: extract_nutrition_value(@recipe[:nutrition], 'タンパク質'),
          carbs: extract_nutrition_value(@recipe[:nutrition], '炭水化物'),
          fat: extract_nutrition_value(@recipe[:nutrition], '脂質'),
          fiber: extract_nutrition_value(@recipe[:nutrition], '食物繊維')
        )
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = "レシピの作成に失敗しました。条件を変更して再試行してください。"
        redirect_to recipe_conditions_new_path and return
      end
    else
      flash[:error] = "レシピの生成に失敗しました。条件を変更して再試行してください。"
      redirect_to recipe_conditions_new_path and return
    end
    redirect_to recipe_path(@recipe_record)
  end
  def show
    @recipe = Recipe.find(params[:id])
  end

  def line_share
    @recipe = Recipe.find(params[:id])
    message = "#{@recipe.name}のレシピをCUISINE AI UTOPIAで作成しました。"
    line_share_url = "https://social-plugins.line.me/lineit/share?url=#{CGI.escape(recipe_url(@recipe))}&text=#{CGI.escape(message)}"
    redirect_to line_share_url
  end

  def share_twitter
    @recipe = Recipe.find(params[:id])
    tweet_text = "#{@recipe.name}のレシピをCUISINE AI UTOPIAで作成しました。"
    tweet_url = "https://twitter.com/intent/tweet?text=#{CGI.escape(tweet_text)}&url=#{CGI.escape(recipe_url(@recipe))}"
    redirect_to tweet_url
  end
  
  private
  
  def extract_nutrition_value(nutrition_text, nutrient)
    return 0 if nutrition_text.blank?
    nutrition_text.match(/#{nutrient}:\s*([\d.]+)/i)&.captures&.first&.to_f || 0
  end
end