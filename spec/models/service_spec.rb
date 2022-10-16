require "rails_helper"

RSpec.describe Service, type: :model do
  subject(:service) { build(:service) }

  it { expect(service).to be_valid }
end
