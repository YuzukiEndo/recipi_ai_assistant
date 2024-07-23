class User < ApplicationRecord
  # Sorceryを使用した認証機能を有効化
  authenticates_with_sorcery!

  # パスワードのバリデーション
  # 新規レコード作成時、またはパスワードが変更された場合にのみ適用
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  # - 最小長さ: 3文字
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  # - パスワード確認が必要

  # パスワード確認のバリデーション
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  # - パスワード確認の存在が必要

  # メールアドレスのバリデーション
  validates :email, presence: true, uniqueness: true
  # - 存在が必要
  # - 一意性が必要
end
