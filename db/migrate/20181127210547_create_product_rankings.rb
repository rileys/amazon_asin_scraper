class CreateProductRankings < ActiveRecord::Migration[5.1]
  def change
    create_table :product_rankings do |t|
      t.belongs_to :product, index: true, foreign_key: true
      t.integer :number, null: false
      t.string :category, null: false
      t.timestamps
    end
  end
end
