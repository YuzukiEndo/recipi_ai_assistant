class RecipeConditionsController < ApplicationController
  skip_before_action :require_login, only: [:new]

  def new
    @categories = ['和食', '洋食', '中華']
    @cooking_times = ['短め', '普通', '長め']
    @ingredients = Ingredient.all
  end

  def create
    # ここでレシピ生成ロジックを実装（後で）やりかたわからん
  end

end
