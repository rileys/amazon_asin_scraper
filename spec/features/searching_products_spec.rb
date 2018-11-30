require 'rails_helper'

feature 'Searching Products' do
  before { visit('/') }

  scenario 'should inform user when no product is found' do
    proxy.stub('https://www.amazon.com:443/dp/123').and_return(code: 404)
    fill_in(:asin, with: 123)
    click_on('Search')

    expect(page).to have_css(:h3, text: 'Product Not Found')
  end

  scenario 'should show searched product result retrieved from scraping' do
    Product.create(asin: 'B00S89FD02', category: 'Stuff > Fun Stuff', dimensions: '10 x 10 x 10 inches')
    fill_in(:asin, with: 'B00S89FD02')
    click_on('Search')

    within('#result') do
      expect(page).to have_content('Stuff > Fun Stuff')
      expect(page).to have_content('10 x 10 x 10 inches')
    end
  end
end
