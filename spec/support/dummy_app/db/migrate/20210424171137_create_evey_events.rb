class CreateEveyEvents < ActiveRecord::Migration::Current
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

    add_index :evey_events, :user_id
  end
end
