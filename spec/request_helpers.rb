module RequestHelpers
  def post(data)
    uri = URI.parse("http://localhost:8080/metrics")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = data.to_json
    http.request(request)
  end
end
