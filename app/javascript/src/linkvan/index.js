import Notifications from "src/linkvan/base/notifications"
import NavbarBurger from "src/linkvan/base/navbar_burger"

export default class Base {
  static start() {
    console.log('Base.start')

    Notifications.start();
    NavbarBurger.start();
  }
}
