require_relative "nonblock"

require "socket"
require "uri"

module Lead
  class Client
    include Nonblock

    attr_reader :uri, :requests, :tcp, :http, :parser

    def initialize(uri:, requests:, tcp: TCPSocket, http: HTTP2::Client, parser: Yajl::Parser)
      @uri = URI(uri)
      @requests = requests
      @tcp = tcp
      @http = http
      @parser = parser
    end

    def request
      connection = tcp.new(uri.host, uri.port)
      protocol = http.new

      protocol.on(:frame) do |data|
        write(io: connection, data: data)
      end

      accept_promises(protocol)

      requests.each do |request|
        puts "requesting #{request}"

        response = {}

        stream = protocol.new_stream
        json = parser.new
        json.on_parse_complete = ->(data) { response[:data] = data }

        stream.on(:headers) do |headers|
          response[:headers] = headers
        end

        stream.on(:data) do |data|
          json << data
        end

        stream.on(:close) do
          puts "response: #{response}"
        end

        stream.headers(request[:headers], end_stream: !request[:data])
        stream.data(request[:data]) if request[:data]
      end

      protocol << read(io: connection) until connection.closed? || connection.eof?
    end

    private

    def authority
      [uri.host, uri.port].join(":")
    end

    def accept_promises(protocol)
      protocol.on(:promise) do |stream|
        response = { data: "" }

        stream.on(:headers) do |headers|
          response[:headers] = headers
        end

        stream.on(:data) do |data|
          response[:data] << data
        end

        stream.on(:close) do
          puts "promise: #{response}"
        end
      end
    end
  end
end
