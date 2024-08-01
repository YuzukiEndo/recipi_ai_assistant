class RecipesController < ApplicationController
  skip_before_action :require_login, only: [:result]

  def result
    @recipe = params.permit(:name, :cooking_time, :category, :ingredients, :instructions, :nutrition).to_h.symbolize_keys
    if @recipe[:name].blank?
      flash[:error] = "レシピの生成に失敗しました。もう一度お試しください。"
      redirect_to recipe_conditions_new_path
    end
  end
  
end