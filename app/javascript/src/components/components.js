import FacilityForm from './facility_form';
import FacilityShow from './facility_show';

export default class Components {
  static start() {
    console.log('Components.start')

    FacilityForm.start();
    FacilityShow.start();
  }
}
