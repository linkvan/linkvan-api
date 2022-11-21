import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("AutoSubmit Connected")
  }

  change(event) {
    this.element.submit(event)
  }

  submit(_event) {
    this.element.submit()
  }
}
