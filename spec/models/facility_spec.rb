require "rails_helper"
require 'support/shared_examples/discardable'

RSpec.describe Facility, type: :model do
  subject(:facility) { build(:facility) }

  it { expect(facility).to be_valid }

  include_examples :discardable do
    subject(:model) { facility }
  end

  describe "#discard_reason" do
    subject(:facility) { build(:facility) }

    before do
      facility.discard_reason = discard_reason
    end

    context "with none" do
      let(:discard_reason) { :none }

      it { expect(facility).to be_discard_reason_none }
    end
  end
end
