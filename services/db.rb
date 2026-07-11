# frozen_string_literal: true

require 'securerandom'
require 'sequel'

DB_DIR = File.join(__dir__, '..', 'db')
Dir.mkdir(DB_DIR) unless Dir.exist?(DB_DIR)

DB_PATH = File.join(DB_DIR, 'users.db')
DB = Sequel.sqlite(DB_PATH)

if DB.table_exists?(:users)
  column_names = DB.schema(:users).map { |column| column[0] }

  unless column_names.include?(:token)
    DB.add_column :users, :token, String

    DB[:users].where(token: nil).each do |user|
      DB[:users].where(id: user[:id]).update(token: SecureRandom.hex(16))
    end
  end
else
  DB.create_table :users do
    primary_key :id
    String :username, unique: true, null: false
    String :password_hash, null: false
    String :token, unique: true, null: false
    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  end
end
