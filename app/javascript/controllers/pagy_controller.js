import { Controller } from "@hotwired/stimulus"
import Pagy from "pagy-module"

// To connect use: data-controller="pagy"
export default class extends Controller {
  connect() {
    console.log("Pagy connect")
    Pagy.init(this.element)
  }
}
