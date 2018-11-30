class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :asin, null: false, index: true
      t.string :category
      t.string :dimensions

      t.timestamps
    end
  end
end
