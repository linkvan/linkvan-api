# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

namespace :pagy do
  namespace :sync do
    desc "Sync Pagy JavaScript files"
    task :javascript do
      require "pagy"
      Pagy.sync(:javascript, Rails.root.join("app/javascript"), "pagy.min.js")
    end
  end
end
