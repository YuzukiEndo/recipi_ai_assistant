const path = require('path');

module.exports = {
  mode: 'production',
  entry: './app/javascript/packs/application.js',
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'app/assets/builds'),
  },
};