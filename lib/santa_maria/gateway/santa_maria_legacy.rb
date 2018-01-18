module SantaMaria
  module Gateway
    class SantaMariaLegacy
      def initialize(endpoint)
        @endpoint = endpoint
      end

      def all_products
        response = Net::HTTP.get_response(URI("#{endpoint}api/products/eukdlx"))

        result = JSON.parse(response.body)

        result['products'].each do |p|
          product = SantaMaria::Domain::Product.new(self)
          product.global_id = p['globalId']
          product.type = p['productType']
          product.name = p['name']
          product.uri_name = p['uriFriendlyName']
          product.description = p['localSlogan']
          product.image_url = p.dig('packshots', 'm')

          yield product
        end
      end

      def variants_for(global_id)
        response = Net::HTTP.get_response(URI("#{endpoint}api/products/eukdlx/#{global_id}"))

        product = JSON.parse(response.body)

        product['packages'].map do |package|
          variant = SantaMaria::Domain::Variant.new
          variant.article_number = package['articleNumber']
          variant.price = package['price']
          variant.name = package['colorTranslation']
          variant.color_id = package['colorId']
          variant.pack_size = package['friendlyPackSize']
          variant.pattern = package['patternId']
          variant.ean = package['EANCode']
          variant.valid = package['validEcomData']
          variant.on_sale = package['readyForSale']
          variant.ready_mix = !package['tintedOrReadyMix'].eql?('Tinted')

          variant
        end
      end

      private

      attr_reader :endpoint
    end
  end
end
