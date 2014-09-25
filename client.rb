require_relative "lib/lead"

module Lead
  request = { headers: { "method" => "get", "path" => "/" } }
  requests = 50.times.collect { request }

  Client.new(uri: "http://localhost:8080", requests: requests).request
end
