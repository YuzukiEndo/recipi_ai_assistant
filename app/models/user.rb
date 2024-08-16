class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :favorites
  has_many :favorite_recipes, through: :favorites, source: :recipe
  has_many :nutrition_logs
  
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, presence: true, uniqueness: true
  
  validates :reset_password_token, uniqueness: true, allow_nil: true

end
