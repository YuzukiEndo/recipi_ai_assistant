class NutritionLog < ApplicationRecord
  belongs_to :user

  validates :calories, :protein, :fat, :carbs, :fiber, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :date, presence: true
  
end