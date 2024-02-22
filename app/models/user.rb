class User < ApplicationRecord
    has_many :topics
    broadcasts_refreshes
end
