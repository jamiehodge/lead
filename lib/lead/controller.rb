class Controller

  attr_reader :model, :encoder

  def initialize(model: , encoder: Yajl::Encoder)
    @model = model
    @encoder = encoder
  end

  def list(request:, response:, params:)
    send_promises(response)

    data = model.to_json
    headers = {
      "status" => "200",
      "content-length" => data.bytesize.to_s,
      "content-type" => "application/json"
    }

    response.headers(headers)
    response.data(data)
  end

  private

  def send_promises(response)
    5.times do
      data = "my model"
      headers = {
        "status" => "200",
        "path" => "/model.rb",
        "content-type" => "text/plain",
        "content-length" => data.bytesize.to_s,
        "etag" => data.hash.to_s
      }

      response.promise(headers) do |stream|
        stream.headers(headers)
        stream.data(data)
      end
    end
  end
end
