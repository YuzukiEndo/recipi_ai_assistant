class FavoritesController < ApplicationController
  before_action :require_login

  def index
    @favorite_recipes = current_user.favorite_recipes
  end
  
  def create
    @recipe = Recipe.find(params[:recipe_id])
    current_user.favorites.create(recipe: @recipe)
    redirect_back fallback_location: root_path, notice: 'レシピをお気に入りに追加しました'
  end

  def destroy
    @favorite = current_user.favorites.find(params[:id])
    @favorite.destroy
    redirect_back fallback_location: root_path, notice: 'お気に入りから削除しました'
  end
end
