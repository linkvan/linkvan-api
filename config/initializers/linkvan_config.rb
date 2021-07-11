linkvan_config_file = Rails.root.join('config/linkvan_config.yml')
config_data = YAML.load_file(linkvan_config_file).with_indifferent_access

LinkvanConfig = OpenStruct.new(config_data)
