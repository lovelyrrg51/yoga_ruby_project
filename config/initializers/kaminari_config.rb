Kaminari.configure do |config|
  config.default_per_page = DEFAULT_RECORDS_PER_PAGE
  config.max_per_page = MAX_RECORDS_PER_PAGE
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end
