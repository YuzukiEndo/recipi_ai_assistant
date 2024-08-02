class Recipe < ApplicationRecord
  has_many :favorites
  has_many :favorited_by, through: :favorites, source: :user
end
