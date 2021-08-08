// #######
// Based on codepen:
//   https://codepen.io/aligoren/pen/KxPxMw
//
// To use this class:
// - With an id:
//   const modalCard = ModalCardComponent.start('modal-card-id')
// - With a selector:
//   const modalCard = new ModalCardComponent("#modal-card-id")
//
//#######
export default class ModalCardComponent {
  static start(elemId) {
    return new ModalCardComponent("#" + elemId);
  }

  constructor(selector) {
    this.elem = document.querySelector(selector)
    console.log('ModalCardComponent constuctor', selector , this.elem);

    this.close_data()
  }

  show() {
    this.elem.classList.toggle('is-active')
    this.on_show()
  }

  close() {
    this.elem.preventDefault();
    this.elem.classList.toggle('is-active')
    this.on_close()
  }

  close_data() {
    var modalClose = this.elem.querySelectorAll("[data-bulma-modal='close'], .modal-background")
    var that = this
    modalClose.forEach(function(e) {
      e.addEventListener("click", function() {

        that.elem.classList.toggle('is-active')

        var event = new Event('modal:close')

        that.elem.dispatchEvent(event);
      })
    })
  }

  on_show() {
    var event = new Event('modal:show')

    this.elem.dispatchEvent(event);
  }

  on_close() {
    var event = new Event('modal:close')

    this.elem.dispatchEvent(event);
  }

  addEventListener(event, callback) {
    this.elem.addEventListener(event, callback)
  }
}
