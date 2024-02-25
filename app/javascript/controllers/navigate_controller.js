/*
 * Base on stimulusJs controller from:
 * - https://rapidruby.com/lessons/19-dynamic-forms-in-hotwire
 */

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigate"
export default class extends Controller {
  static targets = ["container"];
  connect() {
    console.log("Navigate Controller Connected", this.element);
  }

  /*
   * Usage
   * =====
   *
   * add data-controller="navigate" to the turbo frame you want to navigate
   *
   * Action (add to radio input):
   * data-action="change->navigate#to"
   * data-url="/new?input=yes"
   *
   */
  to(e) {
    e.preventDetfault();

    const { url } = e.target.dataset;
    navigateTo(url);
  }

  private

  navigateTo(url) {
    this.containerTargets.forEach(container => {
      container.src = url;
    });
  }
}
