class Recipe < ApplicationRecord
  has_many :favorites
  has_many :users, through: :favorites

  validates :name, presence: true
  validates :cooking_time_minutes, presence: true
  validates :ingredients, presence: true
  validates :instructions, presence: true
  validates :name, presence: true, length: { maximum: 20 }
end