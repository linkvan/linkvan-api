
console.log('notifications.js loaded');

/* eslint-env browser */
// import showUploadedFilename from './form_utils/show_uploaded_filename';

export default class Notifications {
  static start() {
    console.log('Notifications.start');
    (document.querySelectorAll('.notification .delete') || []).forEach(($delete) => {
      console.log('delete click event');

      var $notification = $delete.parentNode;

      $delete.addEventListener('click', () => {
        $notification.parentNode.removeChild($notification);
      });
    });

    // 
    // // Toggles display of the content of a Task's Card.
    // const toggleTaskOptions = (cardContainer, showOptions) => {
    // const taskContent = cardContainer.querySelector('.task-content')
    // if (!taskContent) return;

    // if (showOptions) {
    // // display card-content
    // taskContent.style.display = "";
    // } else {
    // // hide card-content
    // taskContent.style.display = "none";
    // }
    // };

  }
};

