require "cgi"
require "uri"

module Lead
  class Router

    attr_reader :routes, :cgi

    def initialize(routes:, cgi: CGI)
      @routes = routes
      @cgi = cgi
    end

    def route(request:, response:)
      routes.detect do |route|
        headers = request.fetch(:headers, {})
        uri = URI(headers.fetch("path", "/"))

        return unless route[:method] == headers["method"] &&
          match = route[:path].match(uri.path)

        captures = Hash[match.names.map(&:to_sym).zip(match.captures)]
        query = cgi.parse(uri.query.to_s)

        route[:controller].send(
          route[:action],
          request: request,
          response: response,
          params: query.merge(captures)
        )
      end
    end
  end
end
