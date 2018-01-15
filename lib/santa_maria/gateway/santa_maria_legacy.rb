module SantaMaria
  module Gateway
    class SantaMariaLegacy
      class Variant
        attr_accessor :article_number
      end

      class Product
        attr_accessor :global_id, :type, :name

        def variants
          response = Net::HTTP.get_response(URI("https://api/api/products/eukdlx/#{global_id}"))

          product = JSON.parse(response.body)

          product['packages'].map do |sku|
            variant = Variant.new
            variant.article_number = sku['articleNumber']
            variant
          end
        end
      end

      def initialize(endpoint)

      end

      def all_products
        response = Net::HTTP.get_response(URI('https://api/api/products/eukdlx'))

        result = JSON.parse(response.body)


        result['products'].each do |p|
          product = Product.new
          product.global_id = p['globalId']
          product.type = p['productType']
          product.name = p['name']

          yield product
        end
      end
    end
  end
end
