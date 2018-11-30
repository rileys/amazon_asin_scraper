class Product < ApplicationRecord
  # asin: string
  # category: string
  # dimensions: string
  has_many :product_rankings, dependent: :destroy

  validates :asin, presence:true, uniqueness: true
  validates :category, presence:true
end
