require "rails_helper"

RSpec.describe Service, type: :model do
  subject(:facility) { build(:facility) }

  it { expect(facility).to be_valid }
  describe "scopes" do
    describe ".with_service" do
    end
  end
end
