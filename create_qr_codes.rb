# db/migrate/20240101000001_create_qr_codes.rb
class CreateQrCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :qr_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :content,          null: false
      t.string  :label
      t.string  :format,           null: false, default: 'svg'
      t.integer :size,             null: false, default: 4
      t.string  :color,            null: false, default: '000000'
      t.string  :background,       null: false, default: 'ffffff'
      t.string  :error_correction, null: false, default: 'm'
      t.text    :image_data
      t.string  :public_token,     null: false
      t.boolean :is_public,        null: false, default: false
      t.integer :scan_count,       null: false, default: 0

      t.timestamps
    end

    add_index :qr_codes, :public_token, unique: true
    add_index :qr_codes, [:user_id, :created_at]
  end
end