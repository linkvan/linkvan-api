require "rails_helper"

RSpec.describe Analytics::AccessToken, type: :model do
  describe ".load" do
    subject(:access_token) { described_class.load(params) }

    before do
      allow(SecureRandom).to receive(:hex).and_return("A_RANDOM_VALUE")
    end

    context "without any parameters" do
      let(:params) { nil }

      it { expect(access_token.uuid).to eq "A_RANDOM_VALUE" }
      it { expect(access_token.session_token).to be_blank }
      it { expect(access_token.data).to be_blank }
    end
  
    context "with params" do
      context "with uuid" do
        let(:params) { { uuid: 'PRESET_VALUE' } }
      
        it { expect(access_token.uuid).to eq('PRESET_VALUE') }
      end

      context "with session_token" do
        let(:params) { { "session-token": session_token } }
        let(:session_token) { 'A_SESSION_TOKEN_VALUE' }

        it { expect(access_token.session_token ).to eq(session_token) }
      end
    end
  end

  describe "#refresh" do
    subject(:access_token) { described_class.new(uuid: uuid, session_token: session_token) }

    let(:uuid) { 'a_uuid_value' }
    let(:session_token) { nil }
    # let(:session_token) { 'a_session_token' }
    let(:new_session_token) { 'a_new_session_token' }

    it "keeps uuid and updates session_token" do
      expect(described_class::JSONWebToken).to receive(:encode).and_return(new_session_token)
      access_token.refresh

      expect(access_token.uuid).to eq(uuid)
      expect(access_token.session_token).to eq(new_session_token)
    end

    it "creates a new valid session_token" do
      travel_to(2.minutes.from_now) do
        access_token.data[:data_key] = 'data_value'
        access_token.refresh
      end

      new_access_token = described_class.new(uuid: access_token.uuid,
                                             session_token: access_token.session_token)

      expect(new_access_token.uuid).to eq(uuid)
      expect(new_access_token.data[:data_key]).to eq('data_value')
    end
  end

  describe "#as_json" do
    let(:access_token) { described_class.new(uuid: nil, session_token: nil) }

    it do
      expect(access_token.as_json).to match('uuid' => a_kind_of(String),
                                            'session-token' => nil)

      access_token.refresh
      expect(access_token.as_json).to match('uuid' => a_kind_of(String),
                                            'session-token' => a_kind_of(String))
    end
  end
end
