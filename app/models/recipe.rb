class Recipe < ApplicationRecord
  has_many :favorites
  has_many :users, through: :favorites

  validates :name, presence: true
  validates :cooking_time_minutes, presence: true
  validates :ingredients, presence: true
  validates :instructions, presence: true
end