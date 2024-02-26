class User < ApplicationRecord
    has_many :topics
    broadcasts_refreshes

    validates_presence_of :name
    validates_presence_of :email
end
