# Amazon Product ASIN scraper.

Web app to scrape and store Amazon product information (Category, Dimensions, and Best Seller Ranks) based on ASIN.

Uses Capybara to load and read product pages.

Product data will be scraped on initial request, saved to the database if found, and returned from the database on subsequent queries.

### Installation

Install Ruby 2.3.3

Install PhantomJS as described for your system here: https://github.com/teampoltergeist/poltergeist

`gem install bundler`

`bundle install`

`rails db:create db:schema:load`

`rails s` to start the server.

### Tests

`rspec` to run the test suite
