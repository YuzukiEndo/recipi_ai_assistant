class NutritionLogsController < ApplicationController
  before_action :require_login

  def index
    @today_log = current_user.nutrition_logs.find_or_initialize_by(date: Date.today)
    @yesterday_log = current_user.nutrition_logs.find_by(date: Date.yesterday)
  end

  def new
    @recipe = Recipe.find(params[:recipe_id])
    @nutrition_log = current_user.nutrition_logs.build(
      calories: @recipe.calories,
      protein: @recipe.protein,
      fat: @recipe.fat,
      carbs: @recipe.carbs,
      fiber: @recipe.fiber,
      date: Date.today
    )
  end

  def create
    @nutrition_log = current_user.nutrition_logs.find_or_initialize_by(date: Date.today)
    
    @nutrition_log.calories = (@nutrition_log.calories || 0) + nutrition_log_params[:calories].to_f
    @nutrition_log.protein = (@nutrition_log.protein || 0) + nutrition_log_params[:protein].to_f
    @nutrition_log.fat = (@nutrition_log.fat || 0) + nutrition_log_params[:fat].to_f
    @nutrition_log.carbs = (@nutrition_log.carbs || 0) + nutrition_log_params[:carbs].to_f
    @nutrition_log.fiber = (@nutrition_log.fiber || 0) + nutrition_log_params[:fiber].to_f
  
    if @nutrition_log.save
      redirect_to nutrition_logs_path, flash: { success: '今回あなたが摂取した食事の栄養価を保存しました。' }
    else
      @recipe = Recipe.find(params[:nutrition_log][:recipe_id])
      render :new
    end
  end

  private

  def nutrition_log_params
    params.require(:nutrition_log).permit(:calories, :protein, :fat, :carbs, :fiber, :date, :recipe_id)
  end
end