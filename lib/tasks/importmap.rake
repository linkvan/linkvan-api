# lib/tasks/importmap.rake
namespace :importmap do
  desc "Download Import Maps JavaScript dependencies"
  task :install => :environment do
    system("./bin/importmap install") || abort("Import Maps installation failed")
  end
end

# Ensure importmap dependencies are installed before assets:precompile
Rake::Task["assets:precompile"].enhance(["importmap:install"])
