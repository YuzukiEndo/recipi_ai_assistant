// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
import $ from 'jquery';

global.$ = global.jQuery = $;

import Rails from "@rails/ujs"

import Turbolinks from "turbolinks"

import * as ActiveStorage from "@rails/activestorage"

import "channels"

import "bootstrap"

import '../stylesheets/application.scss'

document.addEventListener('turbolinks:load', function() {
  const inputs = document.querySelectorAll('.js-input, .recipe-js-input');
  
  inputs.forEach(function(input) {
    input.addEventListener('keyup', function() {
      if (this.value) {
        this.classList.add('not-empty');
      } else {
        this.classList.remove('not-empty');
      }
    });
  });
});

Rails.start()
Turbolinks.start()
ActiveStorage.start()