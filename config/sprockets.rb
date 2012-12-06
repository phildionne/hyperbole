Sinatra::Sprockets.configure do |config|
  config.digest = true              # Append a digest to URLs
  config.compile = true             # On-the-fly compilation
  config.manifest_path = 'assets'
  config.css_compressor = true     # CSS compressor instance
  config.js_compressor = true      # JS compressor instance
end