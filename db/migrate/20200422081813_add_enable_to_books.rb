class AddEnableToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :enable, :boolean, default: true, null: false
  end
end
