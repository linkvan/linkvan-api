import { Controller } from "@hotwired/stimulus"
import "pagy"

// To connect use: data-controller="pagy"
export default class extends Controller {
  connect() {
    console.log("Pagy connect")
    window.Pagy.init(this.element)
  }
}
