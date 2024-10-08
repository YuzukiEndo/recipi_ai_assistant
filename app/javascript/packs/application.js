// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
import $ from 'jquery';

global.$ = global.jQuery = $;

import Rails from "@rails/ujs"

import Turbolinks from "turbolinks"

import * as ActiveStorage from "@rails/activestorage"

//import "channels"

import '../stylesheets/application.scss'

document.addEventListener('turbolinks:load', function() {
  const flashMessages = document.querySelectorAll('.flash-message');
  flashMessages.forEach(message => {
    setTimeout(() => {
      message.style.animation = 'fadeOut 0.5s forwards';
    }, 10000);
  });
});

document.addEventListener('animationend', function(event) {
  if (event.animationName === 'fadeOut') {
    event.target.remove();
  }
});

document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('.favorite-button, .favorite-button-list').forEach(function(button) {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      var form = this.closest('form');
      var url = form.action;
      var starIcon = this.querySelector('.fa-star');

      fetch(url, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        }
      })
      .then(() => {
        if (this.classList.contains('favorite-button')) {
          starIcon.classList.toggle('favorite-active');
        } else if (this.classList.contains('favorite-button-list')) {
          starIcon.classList.toggle('favorite-star-list');
        }
      })
      .catch(error => console.error('Error:', error));
    });
  });
});

document.addEventListener('turbolinks:load', function() {
  if (typeof LineIt !== 'undefined') {
    LineIt.loadButton();
  }
});

Rails.start()
Turbolinks.start()
ActiveStorage.start()