json.extract! topic, :id, :title, :preview, :notes, :url, :created_at, :updated_at
json.url topic_url(topic, format: :json)
