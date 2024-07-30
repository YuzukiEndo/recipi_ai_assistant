class RecipesController < ApplicationController
  skip_before_action :require_login, only: [:result]

  def result
    @recipe = params.permit(:name, :cooking_time, :category, :ingredients, :instructions)
  end
end
