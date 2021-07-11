require "http"
require "json"
require "carbon"

class Carbon::SparkPostAdapter < Carbon::Adapter
  private getter api_key : String
  private getter location : Symbol
  private getter? sandbox : Bool

  def initialize(@api_key, @location, @sandbox = false)
  end

  def deliver_now(email : Carbon::Email)
    Carbon::SparkPostAdapter::Email.new(email, api_key, location, sandbox?).deliver
  end

  class Email
    TRANSMISSION_ENDPOINT = "/api/v1/transmissions"
    private getter email, api_key, location
    private getter? sandbox : Bool

    def initialize(@email : Carbon::Email, @api_key : String, @location : Symbol, @sandbox = false)
    end

    def deliver
      client.post(TRANSMISSION_ENDPOINT, body: params.to_json).tap do |response|
        unless response.success?
          raise JSON.parse(response.body).inspect
        end
      end
    end

    def params
      {
        options: options,
        content:    mail_content,
        recipients: recipient_list,
      }
    end

    def options
      {
        sandbox: sandbox?
      }
    end

    private def recipient_list
      email.to.map do |carbon_address|
        {
          address: {
            name:  carbon_address.name,
            email: carbon_address.address,
          },
        }
      end
    end

    private def mail_content
      {
        from: {
          name:  email.from.name,
          email: email.from.address,
      }.to_h,
        subject: email.subject,
        text:    email.text_body,
        html:    email.html_body,
      }.to_h
    end

    private def base_url
      ["api", location_string, "sparkpost.com"].compact.join(".")
    end

    private def location_string : String | Nil
      if location == :eu
        return "eu"
      end
    end

    @_client : HTTP::Client?

    private def client : HTTP::Client
      @_client ||= HTTP::Client.new(base_url, port: 443, tls: true).tap do |client|
        client.before_request do |request|
          request.headers["User-Agent"] = "carbon_sparkpost_adapter/"
          request.headers["Content-Type"] = "application/json"
          request.headers["Accept"] = "application/json"
          request.headers["Authorization"] = api_key
        end
      end
    end
  end
end
