require_relative '../spec_helper'
require 'net/http'
require 'uri'

describe '/' do
  it 'displays a friendly message' do
    visit '/'

    expect(page).to have_text 'Welcome to Stethoscope'
  end

  it 'displays the last known cpu usage' do
    uri = URI.parse("http://localhost:8080/metrics")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = 'deployment1.job1.0.agent123.cpu 82.96 1454644228'
    http.request(request)

    visit '/'

    expect(page).to have_text '82.96'
  end
end
