class CreateEveyEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :evey_events do |t|
      t.string :type, null: false
      t.bigint :user_id
      t.jsonb :data
      t.jsonb :metadata
      t.jsonb :aggregates
      t.jsonb :associations

      t.timestamps
    end
  end
end
