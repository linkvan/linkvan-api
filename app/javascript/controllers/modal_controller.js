import { Controller } from "stimulus"

export default class extends Controller {

  static targets = ["modal"];

  connect() {
    console.log("Modal Controller Connected", this.element);
  }

  show(event) {
    event.preventDefault();
    event.stopImmediatePropagation();

    this.modalTarget.classList.add('is-active');
  }

  hide(event) {
    event.preventDefault();
    event.stopImmediatePropagation();

    this.modalTarget.classList.remove('is-active');
  }
}
