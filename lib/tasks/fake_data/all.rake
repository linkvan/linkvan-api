# frozen_string_literal: true

namespace :fake_data do
  desc "Create fake data to help development"
  task all: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

    %w[fake_data:users fake_data:facilities fake_data:analytics].each do |task_name|
      puts "- Invoking #{task_name} task"
      # Executes the task and its dependencies, but it only executes the task if it has not already been invoked
      Rake::Task[task_name].invoke
    end
  end
end
