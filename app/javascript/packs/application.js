// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Rails UJS（Unobtrusive JavaScript）をインポート
import Rails from "@rails/ujs"
// Turbolinks（ページ遷移を高速化するライブラリ）をインポート
import Turbolinks from "turbolinks"
// Active Storage（ファイルアップロード機能）をインポート
import * as ActiveStorage from "@rails/activestorage"
// Action Cable（WebSocketを使用したリアルタイム機能）のチャンネルをインポート
import "channels"
// Bootstrap の JavaScript 機能をインポート
import "bootstrap"
// カスタムスタイルシートをインポート
import "../stylesheets/application"

// Turbolinksのロードイベントをリッスン
document.addEventListener('turbolinks:load', () => {
  // ブラウザの戻るボタンが使用された場合（navigation.type == 2）
  if (performance.navigation.type == 2) {
    // ページを強制的にリロード
    location.reload(true);
  }
});

// Rails UJSを起動
Rails.start()
// Turbolinksを起動
Turbolinks.start()
// Active Storageを起動
ActiveStorage.start()