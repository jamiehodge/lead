require_relative "nonblock"

require "socket"
require "http/2"
require "yajl"

module Lead
  class Server
    include Nonblock

    attr_reader :port, :tcp, :http, :parser, :router

    def initialize(router:, port: 8080, tcp: TCPServer, http: HTTP2::Server, parser: Yajl::Parser)
      @port = port
      @tcp = tcp
      @http = http
      @parser = parser
      @router = router
    end

    def listen
      server = tcp.new(port)
      puts "listening on port #{port}"

      loop do
        connection = accept(io: server)

        Thread.new do
          protocol = http.new

          protocol.on(:frame) do |data|
            write(io: connection, data: data) unless connection.closed?
          end

          protocol.on(:stream) do |stream|
            request = {}

            json = parser.new
            json.on_parse_complete = ->(data) { request[:data] = data }

            stream.on(:headers) do |headers|
              request[:headers] = headers
            end

            stream.on(:data) do |data|
              json << data
            end

            stream.on(:half_close) do
              puts "request: #{request}"
              router.route(request: request, response: stream)
            end
          end # stream

          protocol << read(io: connection) until connection.eof?
        end.join # thread
      end # loop
    end
  end
end
