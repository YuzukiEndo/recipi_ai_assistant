class RecipeConditionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @categories = ['和食', '洋食', '中華']
    @cooking_times = ['短め', '普通', '長め']
    @ingredients = Ingredient.all
  end

  def create
    if valid_form_input?
      # 仮のレシピデータ（後で実際の生成ロジックに置き換え）
      @recipe = {
        name: "仮のレシピ名",
        cooking_time: params[:cooking_time],
        category: params[:category],
        ingredients: params[:ingredients],
        instructions: "ここに調理手順が入ります"
      }
      render :create
    else
      flash.now[:danger] = '不適切な入力データです。全ての項目を入力してください。'
      @categories = ['和食', '洋食', '中華']
      @cooking_times = ['短め', '普通', '長め']
      @ingredients = Ingredient.all
      render :new
    end
  end

  private

  def valid_form_input?
    params[:category].present? &&
    params[:cooking_time].present? &&
    params[:ingredients].present?
  end
end
