# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# app/assets/stylesheets holds compiler inputs (cssbundling-rails), not serving assets.
Rails.application.config.assets.excluded_paths = [Rails.root.join("app", "assets", "stylesheets")]
