module SantaMaria
  module Gateway
    class SantaMariaV2
      class Variant
        attr_accessor :article_number
      end

      class Product
        attr_accessor :global_id, :type

        def variants
          response = Net::HTTP.get_response(URI("https://api/api/v2/products/#{global_id}"))

          product = JSON.parse(response.body)

          product['sku'].map do |sku|
            variant = Variant.new
            variant.article_number = sku['articleNumber']
            variant
          end
        end
      end

      def initialize(endpoint)

      end

      def all_products
        response = Net::HTTP.get_response(URI('https://api/api/v2/products'))

        result = JSON.parse(response.body)


        result['products'].each do |p|
          product = Product.new
          product.global_id = p['globalId']
          product.type = p['productType']

          yield product
        end
      end
    end
  end
end
