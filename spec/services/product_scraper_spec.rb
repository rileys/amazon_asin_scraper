require 'rails_helper'

RSpec.describe ProductScraper, type: :feature do
  it 'should return nil on 404' do
    proxy.stub('https://www.amazon.com:443/dp/123').and_return(code: 404)
    product = ProductScraper.new('123').retrieve_product

    expect(product).to be_nil
  end

  it 'should return nil on 503' do
    proxy.stub('https://www.amazon.com:443/dp/123').and_return(code: 503)
    product = ProductScraper.new('123').retrieve_product

    expect(product).to be_nil
  end

  it 'should return a persisted product if the ASIN has already been added' do
    Product.create(asin: 'B00S89FD02', category: 'Stuff > Fun Stuff', dimensions: '10 x 10 x 10 inches')
    proxy.stub('https://www.amazon.com:443/dp/B00S89FD02').and_return(
      body: File.read(Rails.root + 'spec/fixtures/product_html/B00S89FD02_table_category_dimensions_rank.html'),
      code: 200)
    product = ProductScraper.new('B00S89FD02').retrieve_product

    expect(product.category).to eq('Stuff > Fun Stuff')
    expect(product.dimensions).to eq('10 x 10 x 10 inches')
  end

  it 'should return all data from a product with all available in table details' do
    proxy.stub('https://www.amazon.com:443/dp/B00S89FD02').and_return(
      body: File.read(Rails.root + 'spec/fixtures/product_html/B00S89FD02_table_category_dimensions_rank.html'),
      code: 200)
    product = ProductScraper.new('B00S89FD02').retrieve_product

    expect(product.category).to eq('Electronics > Computers & Accessories > Data Storage > USB Flash Drives')
    expect(product.dimensions).to eq('3.1 x 1 x 0.4 inches')
    expect(product.product_rankings.size).to eq(1)
    expect(product.product_rankings.first.number).to eq(6965)
    expect(product.product_rankings.first.category).to eq('Computers & Accessories > Data Storage > USB Flash Drives')
  end

  it 'should return all data from a product with all available in bullet details, and remove "(Top.." text' do
    proxy.stub('https://www.amazon.com:443/dp/B0046DPKBQ').and_return(
      body: File.read(Rails.root + 'spec/fixtures/product_html/B0046DPKBQ_bullets_category_dimensions_rank.html'),
      code: 200)
    product = ProductScraper.new('B0046DPKBQ').retrieve_product

    expect(product.category).to eq('Grocery & Gourmet Food > Cooking & Baking > Syrups, Sugars & Sweeteners > Sugars')
    expect(product.dimensions).to eq('6.5 x 5 x 1.3 inches')
    expect(product.product_rankings.size).to eq(2)
    expect(product.product_rankings.first.number).to eq(1448)
    expect(product.product_rankings.first.category).to eq('Grocery & Gourmet Food')
    expect(product.product_rankings.second.number).to eq(27)
    expect(product.product_rankings.second.category).to eq('Grocery & Gourmet Food > Cooking & Baking > Syrups, Sugars & Sweeteners > Sugars')
  end

  it 'should return data from a product without dimensions available' do
    proxy.stub('https://www.amazon.com:443/dp/B0797JF56S').and_return(
      body: File.read(Rails.root + 'spec/fixtures/product_html/B0797JF56S_without_dimensions.html'),
      code: 200)
    product = ProductScraper.new('B0797JF56S').retrieve_product

    expect(product.dimensions).to be_nil
    expect(product.valid?).to be(true)
  end
end
