import ModalCardComponent from './modal_card_component';

export default class FacilityShow {
  static start() {
    console.log('FacilityShow.start')

    const show_notes_buttons = document.querySelectorAll('.show_notes_button')

    show_notes_buttons.forEach((button) => {
      const dataset = button.dataset
      if (!dataset) return

      const targetModalId = dataset.modalId
      if (!targetModalId) return

      const modalCard = ModalCardComponent.start(targetModalId)

      modalCard.addEventListener('modal:show', () => {
        console.log("opened");
      })

      modalCard.addEventListener('modal:close', () => {
        console.log("closed");
      })

      button.addEventListener('click', () => {
        modalCard.show();
      })
    })
  }
}
