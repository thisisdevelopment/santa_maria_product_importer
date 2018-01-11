module SantaMaria
  module Gateway
    class SantaMariaV2
      class Variant
        attr_accessor :article_number
      end

      class Product
        attr_accessor :global_id

        def variants
          response = Net::HTTP.get_response(URI("https://api/api/v2/products/#{global_id}"))

          variants = JSON.parse(response.body)

          variant = Variant.new
          variant.article_number = variants['sku'][0]['articleNumber']

          [variant]
        end
      end

      def initialize(endpoint)

      end

      def all_products
        response = Net::HTTP.get_response(URI('https://api/api/v2/products'))

        result = JSON.parse(response.body)


        if result['products'].length > 0
          product = Product.new
          product.global_id = result['products'][0]['globalId']

          yield product
        end
      end
    end
  end
end
