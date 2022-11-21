// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// import "@fortawesome/fontawesome-free/js/all";
// import "@fortawesome/fontawesome-free/css/all.css"

// import "bulma"

require("trix")
require("@rails/actiontext")
// Add ability to set colors headings on Trix editor (ActionText)
require("./src/richtext")

import Linkvan from './src/linkvan'
import Components from './src/components'

document.addEventListener("turbo:load", () => {
  Linkvan.start();
  Components.start();

  // Disable ActionText attachments
  window.addEventListener("trix-file-accept", function(event) {
    event.preventDefault()
    alert("File attachment not supported!")
  })
})


