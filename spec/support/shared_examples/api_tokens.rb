# @note: Perform a request before calling this shared example
# @example: before { get <a_path> }
RSpec.shared_examples :api_tokens do
  describe "tokens" do
    describe "cookies" do
      let(:response_cookies) { JSON.parse(response.cookies['_linkvanapi_tokens'], symbolize_names: true) }

      it "includes tokens hash" do
        expect(response).to have_http_status(:success)
        expect(response_cookies).to match(
          a_hash_including('session-token': a_kind_of(String),
                           uuid: a_kind_of(String))
        )
      end
    end
  end
end
