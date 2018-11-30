class ProductRanking < ApplicationRecord
  # number: integer
  # category: string
  belongs_to :product

  validates :number, numericality: true
  validates :category, presence: true
end
