module SantaMaria
  module Gateway
    class SantaMariaV2
      def initialize(endpoint)

      end

      def all_products
        response = Net::HTTP.get_response(URI('https://api/api/v2/products'))

        result = JSON.parse(response.body)


        result['products'].each do |product|
          yield new_product(product)
        end
      end

      def variants_for(global_id)
        response = Net::HTTP.get_response(URI("https://api/api/v2/products/#{global_id}"))

        product = JSON.parse(response.body)

        variants = []

        product['sku'].each do |sku|
          if sku['colorIds'].nil?
            variants << new_variant(sku)
          else
            sku['colorIds'].each do |color|
              variant = new_variant(sku)

              variant.name = color.dig('colorCollectionColors', 0, 'colorTranslation')
              variant.color_id = color.dig('colorCollectionColors', 0, 'colorCollectionColorID')

              variants << variant
            end
          end
        end

        variants
      end

      private

      def new_product(product_data)
        product = SantaMaria::Domain::Product.new(self)
        product.global_id = product_data['globalId']
        product.type = product_data['productType']
        product.name = product_data['name']
        product.uri_name = product_data['uri']
        product.description = product_data['localSlogan']
        product.image_url = product_data.dig('packshots', 0, 'm')
        product
      end

      def new_variant(sku)
        variant = SantaMaria::Domain::Variant.new
        variant.article_number = sku['articleNumber']
        variant.price = sku['price']
        variant.pack_size = sku['friendlyPackSizeTranslation']
        variant.pattern = sku.dig('pattern', 0, 'name')
        variant.ean = sku['eanCode']
        variant.valid = sku['validEcomData']
        variant.on_sale = sku['readyForSale']
        variant.ready_mix = !sku['tintedOrReadyMix'].eql?('Tinted')
        variant
      end
    end
  end
end
