require "spec_helper"

RSpec.describe Vimeo do
  let(:video_id) { 375468729 }

  describe "authorization" do
    context "without authorization" do
      it "raises an error", vcr: true do
        expect {
          Vimeo.resource.get("/videos/#{video_id}")
        }.to raise_error(Vimeo::Unauthorized)
      end
    end

    context "with basic authorization" do
      it "gets the video", vcr: true do
        basic_auth = {username: ENV["VIMEO_CLIENT_ID"], password: ENV["VIMEO_CLIENT_SECRET"]}
        encoded_credentials = Base64.strict_encode64("#{basic_auth[:username]}:#{basic_auth[:password]}")
        headers = {"Authorization" => "basic #{encoded_credentials}"}
        response = Vimeo.resource.get("/videos/#{video_id}", {}, headers)
        expect(response).to be_a(Hashie::Mash)
        expect(response["name"]).to eq("Rick Roll'd")
      end
    end

    context "with oauth authorization" do
      it "gets the video", vcr: true do
        Vimeo.token = ENV["VIMEO_ACCESS_TOKEN"]
        response = Vimeo.resource.get("/videos/#{video_id}")
        expect(response).to be_a(Hashie::Mash)
        expect(response["name"]).to eq("Rick Roll'd")
      end
    end
  end

  describe "rate limiting" do
    let(:endpoint) { "/videos/#{video_id}" }
    let(:url) { "#{Vimeo::Client::BASE_API_URI}#{endpoint}" }
    # TODO: don't slow down tests with this - try timecop etc
    let(:rate_limit_reset_time) { 5 } # Number of seconds to reset rate limit

    before do
      stub_request(:get, url)
        .to_return(
          status: 429,
          headers: {
            "X-RateLimit-Limit" => "100",
            "X-RateLimit-Remaining" => "0",
            "X-RateLimit-Reset" => (Time.now + rate_limit_reset_time).iso8601
          }
        )
        .then
        .to_return(
          status: 200,
          body: '{"uri":"/videos/375468729","name":"Rick Roll''d"}'
        )
    end

    it "sleeps for the right amount of time when rate limited and the next request is successful" do
      start_time = Time.now

      client = Vimeo.resource
      client.request(endpoint)
      client.request(endpoint)

      expect(Time.now - start_time).to be_within(1).of(rate_limit_reset_time)
    end
  end
end
