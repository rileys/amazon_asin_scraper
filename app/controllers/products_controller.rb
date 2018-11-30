class ProductsController < ApplicationController
  def search
    return unless params[:asin].present?
    @product = ProductScraper.new(params[:asin]).retrieve_product
  end
end
