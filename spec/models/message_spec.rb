# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  subject(:message) { build(:message) }

  it { expect(message).to be_valid }

  describe "validations" do
    it { expect(message).to validate_presence_of(:name) }
    it { expect(message).to validate_presence_of(:phone) }
    it { expect(message).to validate_presence_of(:content) }
  end

  describe "ActiveModel behaviors" do
    describe "#to_key" do
      it "returns nil for form objects" do
        expect(message.to_key).to be_nil
      end
    end

    describe "#persisted?" do
      it "returns false for form objects" do
        expect(message.persisted?).to be false
      end
    end
  end

  describe "edge cases" do
    context "with nil name" do
      subject(:message) { build(:message, name: nil) }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:name]).to include("can't be blank") }
    end

    context "with empty name" do
      subject(:message) { build(:message, name: "") }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:name]).to include("can't be blank") }
    end

    context "with whitespace-only name" do
      subject(:message) { build(:message, name: "   ") }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:name]).to include("can't be blank") }
    end

    context "with nil phone" do
      subject(:message) { build(:message, phone: nil) }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:phone]).to include("can't be blank") }
    end

    context "with empty phone" do
      subject(:message) { build(:message, phone: "") }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:phone]).to include("can't be blank") }
    end

    context "with whitespace-only phone" do
      subject(:message) { build(:message, phone: "   ") }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:phone]).to include("can't be blank") }
    end

    context "with nil content" do
      subject(:message) { build(:message, content: nil) }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:content]).to include("can't be blank") }
    end

    context "with empty content" do
      subject(:message) { build(:message, content: "") }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:content]).to include("can't be blank") }
    end

    context "with whitespace-only content" do
      subject(:message) { build(:message, content: "   ") }

      before { message.valid? }

      it { expect(message).not_to be_valid }
      it { expect(message.errors[:content]).to include("can't be blank") }
    end

    context "with valid attributes" do
      subject(:message) { build(:message, name: "Alice", phone: "9876543210", content: "Valid content") }

      it { expect(message).to be_valid }
      it { expect(message.errors).to be_empty }
    end
  end
end
