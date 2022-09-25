# @note: called of this shared example must initialize validate variable
# @example: subject(:model) { build(:facility) }
RSpec.shared_examples :discardable do
  describe "#discard" do
    before do
      model.assign_attributes(deleted_at: initial_deleted_at)
      # model.save!
    end

    context "when not discarded" do
      let(:initial_deleted_at) { nil }

      it { expect(model.discard).to be(true) }
      it { expect { model.discard }.to change(model, :discarded?).to(true) }
      it { expect { model.discard }.to change(model, :undiscarded?).to(false) }
      it { expect { model.discard! }.not_to raise_error }
      it { expect { model.discard! }.to change(model, :discarded?).to(true) }
    end

    context "when discarded" do
      let(:initial_deleted_at) { 1.day.ago }

      it { expect(model.discard).to be(true) }
      it { expect { model.discard }.not_to change(model, :discarded?).from(true) }
      it { expect { model.discard }.not_to change(model, :undiscarded?).from(false) }
      it { expect { model.discard! }.not_to raise_error }
      it { expect { model.discard! }.not_to change(model, :discarded?).from(true) }

    end

    context "when discard fails" do
      let(:initial_deleted_at) { nil }

      before do
        allow(model).to receive(:discard).and_return(false)
      end

      it { expect { model.discard! }.to raise_exception(Discardable::RecordNotDiscarded, "Failed to discard #{described_class}") }
    end
  end

  describe "#undiscard" do
    before do
      model.assign_attributes(deleted_at: initial_deleted_at)
      # model.save!
    end

    context "when not discarded" do
      let(:initial_deleted_at) { nil }

      it { expect(model.undiscard).to be(true) }
      it { expect { model.undiscard }.not_to change(model, :discarded?).from(false) }
      it { expect { model.undiscard }.not_to change(model, :undiscarded?).from(true) }
      it { expect { model.undiscard! }.not_to raise_error }
      it { expect { model.undiscard! }.not_to change(model, :undiscarded?).from(true) }
    end

    context "when discarded" do
      let(:initial_deleted_at) { 1.day.ago }

      it { expect(model.undiscard).to be(true) }
      it { expect { model.undiscard }.to change(model, :discarded?).to(false) }
      it { expect { model.undiscard }.to change(model, :undiscarded?).to(true) }
      it { expect { model.undiscard! }.not_to raise_error }
      it { expect { model.undiscard! }.to change(model, :undiscarded?).to(true) }
    end

    context "when undiscard fails" do
      let(:initial_deleted_at) { nil }

      before do
        allow(model).to receive(:undiscard).and_return(false)
      end

      it { expect { model.undiscard! }.to raise_exception(Discardable::RecordNotUnDiscarded, "Failed to undiscard #{described_class}") }
    end
  end
end
