class CreateOrgs < ActiveRecord::Migration[6.1]
  def change
    create_table :orgs do |t|
      t.string :name
      t.bigint :owner_id

      t.timestamps
    end
  end
end
