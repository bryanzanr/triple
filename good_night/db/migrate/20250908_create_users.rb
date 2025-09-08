# db/migrate/20250908_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.1]
    def change
        create_table :users do |t|
            t.string :name, null: false
            t.timestamps
        end
    end
end