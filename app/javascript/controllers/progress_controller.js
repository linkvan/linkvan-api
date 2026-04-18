import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator", "message"]

  connect() {
    console.log("Progress Controller Connected", this.element)
  }

  submit(event) {
    const form = event.currentTarget
    const button = form.querySelector('input[type="submit"], button[type="submit"]')
    const operation = form.dataset.operation

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = this.getMessage(operation)
    }

    if (button) {
      button.classList.add("is-loading")
      button.disabled = true
    }

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.remove("is-hidden")
    }
  }

  getMessage(operation) {
    const messages = {
      import: "Importing facilities from Vancouver City API...",
      discard: "Discarding facilities from Vancouver City API..."
    }
    return messages[operation] || "Processing..."
  }
}
