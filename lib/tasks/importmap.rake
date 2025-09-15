# lib/tasks/importmap.rake
# This file prevents Rails from running importmap:install during Heroku deployment
# which would overwrite our custom importmap configuration.

namespace :importmap do
  desc "Prevent importmap:install from overwriting config during deployment"
  task :install do
    puts "Skipping importmap:install - configuration already exists"
  end
end
