Capybara.register_driver :poltergeist_scraper do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
