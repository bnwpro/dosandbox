class Topic < ApplicationRecord
  belongs_to :user, touch: true
	broadcasts_refreshes

  validates :title, presence: true
end
