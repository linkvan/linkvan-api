RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  
  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  #########
  # To set a specific spec with a specific type:
  #   RSpec.describe UsersController, type: :controller do
  #     # ...
  #   end
  # Customize Extra Tags as default type
  # Serializers specs
  config.define_derived_metadata(file_path: Regexp.new('/spec/serializers/')) do |metadata|
    metadata[:type] = :serializer
  end

  # Support specs
  #   For some reason, capybara didn't recognize system specs as feature.
  config.define_derived_metadata(file_path: Regexp.new('/spec/system/')) do |metadata|
    metadata[:type] = :feature
  end
  
end
