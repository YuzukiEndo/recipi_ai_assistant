process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

const config = environment.toWebpackConfig()

// 問題のある node 設定を削除
delete config.node

module.exports = config