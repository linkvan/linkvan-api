import Notifications from "./base/notifications"
import NavbarBurger from "./base/navbar_burger"

export default class Base {
  static start() {
    console.log('Base.start')

    Notifications.start();
    NavbarBurger.start();
  }
}
