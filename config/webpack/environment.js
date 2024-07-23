const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

// jQuery と Popper.js をグローバルに利用可能にするための設定
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  // $とjQueryをグローバル変数として定義
  $: 'jquery',
  jQuery: 'jquery',
  // Popper.jsをグローバル変数として定義（Bootstrapのドロップダウンなどに必要）
  Popper: ['popper.js', 'default']
}))


module.exports = environment