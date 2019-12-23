class CreateEncouragements < ActiveRecord::Migration
  def change
    create_table :encouragements do |t|
      t.references :user, index: true, foreign_key: true
      t.references :achievement, index: true, foreign_key: true
      t.string :message

      t.timestamps null: false
    end
  end
end
