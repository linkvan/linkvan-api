
export default class FacilityForm {
  static start() {
    console.log('FacilityForm.start')

    const toggleNote = (checkbox) => {
      const targetNote = checkbox.dataset.targetNote
      const noteInput = targetNote && document.getElementById(targetNote)

      if (!!noteInput) {
        if (checkbox.checked) {
          noteInput.style.display = 'block';
        } else {
          noteInput.style.display = 'none';
        }
      }
    }
    
    const serviceCheckboxes = document.querySelectorAll('input[type=checkbox]');
    serviceCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener('click', () => {
        toggleNote(checkbox);
      })

      toggleNote(checkbox);
    })
  }
}
