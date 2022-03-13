class GenerateKeysOnServices < ActiveRecord::Migration[6.1]
  def up
    Service.all.each do |service|
      service.update(key: service.name.parameterize.underscore)
    end
  end

  def down
  end
end
