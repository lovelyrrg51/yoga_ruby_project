PDFKit.configure do |config|

  config.wkhtmltopdf = (defined?(Bundler::GemfileError) && File.exists?('Gemfile') ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
  config.default_options = {
      :page_size     => 'A4',
	  :margin_top    => '0.10in',
	  :margin_right  => '0.10in',
	  :margin_bottom => '0.10in',
	  :margin_left   => '0.10in',
	  :quiet         => false
  }
end