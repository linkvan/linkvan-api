require "rails_helper"
require 'support/shared_examples/discardable'

RSpec.describe Facility, type: :model do
  subject(:facility) { build(:facility) }

  it { expect(facility).to be_valid }

  include_examples :discardable do
    subject(:model) { facility }
  end
end
