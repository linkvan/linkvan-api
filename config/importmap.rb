# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.16
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/actiontext", to: "@rails--actiontext.js" # @8.0.201
pin "trix" # @2.1.15
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.12
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.13
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.0.201

# Pin Pagy JavaScript module
pin "pagy", to: "pagy.min.js"

# Pin controllers individually for better importmap compatibility
pin "controllers", to: "controllers/index.js"
pin "controllers/application"
pin "controllers/auto_submit_controller"
pin "controllers/hello_controller"
pin "controllers/modal_controller" 
pin "controllers/navigate_controller"
pin "controllers/pagy_controller"

# Pin local JavaScript modules individually
pin "src/richtext"
pin "src/linkvan", to: "src/linkvan/index.js"
pin "src/linkvan/index"
pin "src/linkvan/base/navbar_burger"
pin "src/linkvan/base/notifications"
pin "src/components", to: "src/components/index.js"
pin "src/components/index"
pin "src/components/facility_form"
pin "src/components/facility_show"
pin "src/components/modal_card_component"
