import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["modalContainer"];

  connect() {
    console.log("Modal Controller Connected", this.element, this.modalContainerTarget);
  }

  show(event) {
    event.preventDefault();
    event.stopImmediatePropagation();

    console.log("Modal Show!!!");
    this.modalContainerTarget.classList.add('is-active');
  }

  hide(event) {
    event.preventDefault();
    event.stopImmediatePropagation();

    this.modalContainerTarget.classList.remove('is-active');
  }
}

