class Seed < ActiveRecord::Migration[6.1]
  def change
    # Runs seed.rb to make sure the platform has the proper setup data
    Rails.application.load_seed
  end
end
