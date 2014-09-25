require "sequel"

module Lead
  DB = Sequel.sqlite

  DB.create_table(:articles) do
    primary_key(:id)
    text(:title)
    text(:body)
  end

  class Article < Sequel::Model
    plugin :json_serializer
  end
end
