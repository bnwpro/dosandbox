class Topic < ApplicationRecord
  belongs_to :user, touch: true
	broadcasts_refreshes

  validates_presence_of :title
end
