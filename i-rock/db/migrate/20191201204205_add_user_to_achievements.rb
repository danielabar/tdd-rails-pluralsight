class AddUserToAchievements < ActiveRecord::Migration
  def change
    add_reference :achievements, :user, index: true, foreign_key: true
  end
end
