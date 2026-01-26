require "rails_helper"

RSpec.describe Status, type: :model do
  subject(:status) { build(:status) }

  it { expect(status).to be_valid }

  describe "attributes" do
    it { should respond_to(:fid) }
    it { should respond_to(:changetype) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe "creation and persistence" do
    let(:status) { create(:status) }

    it "can be created and saved" do
      expect(status).to be_persisted
      expect(status.id).to be_present
    end

    it "can be retrieved from database" do
      found_status = Status.find(status.id)
      expect(found_status.fid).to eq(status.fid)
      expect(found_status.changetype).to eq(status.changetype)
    end
  end

  describe "attribute assignment" do
    it "allows assignment of fid" do
      status.fid = 999
      expect(status.fid).to eq(999)
    end

    it "allows assignment of changetype" do
      status.changetype = "new_changetype"
      expect(status.changetype).to eq("new_changetype")
    end
  end
end
