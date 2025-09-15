import FacilityForm from "src/components/facility_form";
import FacilityShow from "src/components/facility_show";

export default class Components {
  static start() {
    console.log('Components.start')

    FacilityForm.start();
    FacilityShow.start();
  }
}
