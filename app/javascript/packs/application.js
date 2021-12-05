// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
ActiveStorage.start()

import "@fortawesome/fontawesome-free/js/all";
import "@fortawesome/fontawesome-free/css/all.css"

import "bulma"

import "../stylesheets/application"

import "controllers"

require("trix")
require("@rails/actiontext")
// Add ability to set colors headings on Trix editor (ActionText)
require("../src/richtext")

import Linkvan from '../src/linkvan/linkvan'

document.addEventListener("turbo:load", () => {
  Linkvan.start();

  // Disable ActionText attachments
  window.addEventListener("trix-file-accept", function(event) {
    event.preventDefault()
    alert("File attachment not supported!")
  })
})


