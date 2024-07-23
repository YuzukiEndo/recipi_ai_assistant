class PagesController < ApplicationController
  # ホームページへのアクセスには認証を必要としない
  skip_before_action :require_login, only: [:home]

  # ホームページのキャッシュを無効にする
  before_action :no_cache, only: [:home]

  # トップページ（ホーム）のアクション
  def home
    # 現時点では特別な処理は不要
  end

  private

  # ブラウザのキャッシュを無効にするメソッド
  def no_cache
    # キャッシュを無効にし、常に最新のコンテンツを要求するよう指示
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    # HTTP/1.0クライアントのためのキャッシュ無効化指示
    response.headers["Pragma"] = "no-cache"
    # 過去の日付を指定することで、コンテンツが既に期限切れであることを示す
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
