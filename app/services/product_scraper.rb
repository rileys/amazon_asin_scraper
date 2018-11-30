require 'capybara/poltergeist'

class ProductScraper
  def initialize(asin)
    @asin = asin
  end

  # Find the product in the database or scrape it and save.
  def retrieve_product
    product = Product.find_by(asin: @asin)
    return product if product.present?
    scrape_product
  end

  private

  def scrape_product
    session = Capybara::Session.new(:poltergeist_scraper)
    # Use a common User-Agent.  Could rotate popular ones to simulate different users.
    session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36' }
    session.visit("https://www.amazon.com/dp/#{@asin}")

    # Skip if 404 Not found, 503 Robot Check
    return nil unless session.status_code == 200

    product = Product.new(asin: @asin)
    set_category(session, product)
    set_dimensions(session, product)
    set_product_rankings(session, product)

    product.save
    product
  end

  # Find each link text in the categories breadcrumbs and join.
  def set_category(session, product)
    category_links = session.all(:css, '#wayfinding-breadcrumbs_feature_div a')
    product.category = category_links.map(&:text).join(' > ')
  end

  # Find the table or bullet item for 'Product Dimensions', get its parent content and match the dimension content.
  def set_dimensions(session, product)
    begin
      dimension_string = session.find('.prodDetTable th, #detail-bullets b', text: 'Product Dimensions').find(:xpath, '..').text
      product.dimensions = dimension_string.match(/Product Dimensions:? (.*)/).captures.first
    rescue Capybara::ElementNotFound => e
      # Some products don't have dimensions.
    end
  end

  # Find the table or bullet item for 'Best Sellers Rank', get its parent content and extract each ranking.
  def set_product_rankings(session, product)
    # Split Rank row text on '#'
    rank_strings = session.find('.prodDetTable th, li b', text: 'Best Sellers Rank').find(:xpath, '..').text.split('#')
    # Remove the 'Best Sellers' item
    rank_strings.shift

    rank_strings.each do |rank_string|
      # Find a match each from the string for number and category.
      number, category = rank_string.match(/([^\s]+) in (.*)/).captures

      # Remove '(See Top..' trailing text from category if it exists.
      see_top_index = category.index(" (See ")
      category.slice!(see_top_index..-1) if see_top_index
      product.product_rankings << ProductRanking.new(number: number.delete(','), category: category)
    end
  end
end
