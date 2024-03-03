// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AutoSubmitController from "./auto_submit_controller"
application.register("auto-submit", AutoSubmitController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import ModalController from "./modal_controller"
application.register("modal", ModalController)

import NavigateController from "./navigate_controller"
application.register("navigate", NavigateController)

import PagyController from "./pagy_controller"
application.register("pagy", PagyController)
