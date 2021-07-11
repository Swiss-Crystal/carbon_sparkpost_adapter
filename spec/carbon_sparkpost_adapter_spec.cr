require "./spec_helper"

describe Carbon::SparkPostAdapter do
  # Only enable with proper setup
  {% if flag?("with-integration") %}
  describe "deliver_now" do
    it "delivers the email successfully" do
      send_email_to_spark_post text_body: "THIS IS A MESSAGE FROM US",
        from: Carbon::Address.new("anything@sparkpostbox.com"),
        subject: "CARBON TEST MAIL",
        html_body: "<b>WOW</b>",
        to: [Carbon::Address.new("random@mail.com")]
    end
  end
  {% end %}

  describe "params" do
    it "sets personalizations" do
      to_without_name = Carbon::Address.new("to@example.com")
      to_with_name = Carbon::Address.new("Jimmy", "to2@example.com")

      recipient_params = params_for(
        to: [to_without_name, to_with_name],
      )

      recipient_params[:recipients].should eq(
        [
          {address: {name: nil, email: "to@example.com"}},
          {address: {name: "Jimmy", email: "to2@example.com"}},
        ]
      )
    end

    it "sets the subject" do
      params_for(subject: "My subject")[:content][:subject].should eq "My subject"
    end

    it "sets the from address" do
      address = Carbon::Address.new("from@example.com")
      params_for(from: address)[:content][:from].should eq({name: nil, email: "from@example.com"}.to_h)

      address = Carbon::Address.new("Sally", "from@example.com")
      params_for(from: address)[:content][:from].should eq({name: "Sally", email: "from@example.com"}.to_h)
    end

    it "sets the content" do
      params_for(text_body: "text")[:content][:text].should eq "text"
      params_for(html_body: "html")[:content][:html].should eq "html"
      params_for(text_body: "text", html_body: "html")[:content].should eq(
        {from: {name: nil, email: "from@example.com"}.to_h, subject: "subject", text: "text", html: "html"}.to_h,
      )
    end
  end
end

private def params_for(**email_attrs)
  email = FakeEmail.new(**email_attrs)
  Carbon::SparkPostAdapter::Email.new(email, api_key: "fake_key", location: :eu).params
end

private def send_email_to_spark_post(**email_attrs)
  api_key = ENV.fetch("SPARK_POST_API_KEY")
  email = FakeEmail.new(**email_attrs)
  adapter = Carbon::SparkPostAdapter.new(api_key: api_key, sandbox: true, location: :eu)
  adapter.deliver_now(email)
end
