class FavoritesController < ApplicationController
  before_action :require_login

  def index
    @favorite_recipes = current_user.favorites.includes(:recipe).page(params[:page]).per(5)
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    favorite = current_user.favorites.find_or_initialize_by(recipe: @recipe)

    if favorite.persisted?
      favorite.destroy
    else
      favorite.save
    end

    head :ok
  end
end