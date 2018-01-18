module SantaMaria
  module Gateway
    class SantaMariaV2
      class Product
        attr_accessor :global_id, :type, :name, :uri_name, :description, :image_url

        def variants
          response = Net::HTTP.get_response(URI("https://api/api/v2/products/#{global_id}"))

          product = JSON.parse(response.body)

          variants = []

          product['sku'].each do |sku|
            if sku['colorIds'].nil?
              variant = SantaMaria::Domain::Variant.new
              variant.article_number = sku['articleNumber']
              variant.price = sku['price']
              variant.pack_size = sku['friendlyPackSizeTranslation']
              variant.pattern = sku.dig('pattern', 0, 'name')
              variant.ean = sku['eanCode']
              variant.valid = sku['validEcomData']
              variant.on_sale = sku['readyForSale']
              variant.ready_mix = !sku['tintedOrReadyMix'].eql?('Tinted')
              variants << variant
            else
              sku['colorIds'].each do |color|
                variant = SantaMaria::Domain::Variant.new
                variant.article_number = sku['articleNumber']
                variant.price = sku['price']

                variant.name = color.dig('colorCollectionColors', 0, 'colorTranslation')
                variant.color_id = color.dig('colorCollectionColors', 0, 'colorCollectionColorID')

                variant.pack_size = sku['friendlyPackSizeTranslation']
                variant.pattern = sku.dig('pattern', 0, 'name')
                variant.ean = sku['eanCode']
                variant.valid = sku['validEcomData']
                variant.on_sale = sku['readyForSale']
                variant.ready_mix = !sku['tintedOrReadyMix'].eql?('Tinted')

                variants << variant
              end
            end
          end

          variants
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
          product.name = p['name']
          product.uri_name = p['uri']
          product.description = p['localSlogan']
          product.image_url = p.dig('packshots', 0, 'm')

          yield product
        end
      end
    end
  end
end
