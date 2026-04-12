import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link", "content"]

  initialize() {
    this.activeTab = this.element.dataset.activeTab || "sync"
  }

  connect() {
    console.log("Tabs Controller Connected", this.element);

    this.boundSwitchTab = this.switchTab.bind(this)
    this.linkTargets.forEach((link) => {
      link.addEventListener('click', this.boundSwitchTab)
    })
    this.activateTab(this.activeTab)
  }

  disconnect() {
    this.linkTargets.forEach((link) => {
      link.removeEventListener('click', this.boundSwitchTab)
    })
  }

  switchTab(event) {
    event.preventDefault()

    const tab = event.currentTarget.dataset.tab
    this.activateTab(tab)
  }

  activateTab(tab) {
    this.linkTargets.forEach((link) => {
      if (link.dataset.tab === tab) {
        link.closest("li").classList.add("is-active")
      } else {
        link.closest("li").classList.remove("is-active")
      }
    })

    this.contentTargets.forEach((content) => {
      if (content.id === tab) {
        content.classList.remove("is-hidden")
      } else {
        content.classList.add("is-hidden")
      }
    })

    this.activeTab = tab
  }
}
