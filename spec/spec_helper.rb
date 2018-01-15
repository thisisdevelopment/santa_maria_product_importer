require "bundler/setup"
require "santa_maria/use_case/fetch_products"
require "santa_maria/gateway/santa_maria_v2"
require "santa_maria/gateway/santa_maria_legacy"
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define :a_product do |expected_product|
  match do |product|
    expected_product[:global_id] == product.global_id &&
      expected_product[:type] == product.type &&
      expected_product[:name] == product.name &&
      expected_product[:uri_name] == product.uri_name
  end
end

RSpec::Matchers.define :a_product_with_variants do |expected_variants|
  match do |product|
    matches = product.variants.each_with_index.map do |variant, i|
      variant.article_number == expected_variants[i][:article_number]
    end

    !matches.include?(false)
  end
end
