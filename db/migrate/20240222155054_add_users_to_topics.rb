class AddUsersToTopics < ActiveRecord::Migration[7.1]
  def change
    add_reference :topics, :user, foreign_key: true
  end
end
