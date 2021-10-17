import Notifications from "./base/notifications"
import NavbarBurger from "./base/navbar_burger"
import Pagy from "./base/pagy.js.erb"
// import './base/pagy.js.erb'

export default class Base {
  static start() {
    console.log('Base.start')

    Notifications.start();
    NavbarBurger.start();
    Pagy.start();
  }
}
