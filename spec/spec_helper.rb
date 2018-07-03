require "bundler/setup"
require "santa_maria/product_importer"
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

RSpec::Matchers.define :a_color do |expected_color|
  match do |color|
    expected_color[:color_id] == color.color_id &&
      expected_color[:rgb] == color.rgb
  end
end

RSpec::Matchers.define :a_product do |expected_product|
  match do |product|
    expected_product[:global_id] == product.global_id &&
      expected_product[:type] == product.type &&
      expected_product[:name] == product.name &&
      expected_product[:uri_name] == product.uri_name &&
      expected_product[:description] == product.description &&
      expected_product[:image_url] == product.image_url
  end
end

RSpec::Matchers.define :a_product_with_variants do |expected_variants|
  match do |product|
    variants = product.variants
    matches = variants.each_with_index.map do |variant, i|
      variant.article_number == expected_variants[i][:article_number] &&
        variant.price == expected_variants[i][:price] &&
        variant.valid? == expected_variants[i][:valid] &&
        variant.on_sale? == expected_variants[i][:on_sale] &&
        variant.color_id == expected_variants[i][:color_id] &&
        variant.ready_mix? == expected_variants[i][:ready_mix] &&
        variant.pack_size == expected_variants[i][:pack_size] &&
        variant.pattern == expected_variants[i][:pattern] &&
        variant.ean == expected_variants[i][:ean] &&
        variant.name == expected_variants[i][:name] &&
        variant.version == expected_variants[i][:version]
    end

    !matches.include?(false)
  end
end
