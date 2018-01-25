lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'santa_maria/product_importer/version'

Gem::Specification.new do |spec|
  spec.name          = 'santa_maria-product_importer'
  spec.version       = SantaMaria::ProductImporter::VERSION
  spec.authors       = ['Craig J. Bass']
  spec.email         = ['craig@madetech.com']

  spec.summary       = %q{SantaMaria API libary}
  spec.description   = %q{This provides a consistent Ruby interface around SantaMaria APIs.}
  spec.homepage      = 'https://github.com/madetech/santa_maria-product_importer'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.0'
end
