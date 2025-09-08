# db/migrate/20250908_create_sleep_records.rb
class CreateSleepRecords < ActiveRecord::Migration[7.1]
    def change
        create_table :sleep_records do |t|
            t.references :user, null: false, foreign_key: true
            t.datetime :started_at, null: false
            t.datetime :ended_at
            t.integer :duration_sec
            t.timestamps
        end
        
        add_index :sleep_records, [:user_id, :started_at]
        add_index :sleep_records, [:user_id, :ended_at]

        # One open record per user
        add_index :sleep_records, :user_id, unique: true, where: "ended_at IS NULL", name: "index_sleep_records_on_user_id_where_open"
    end
end