module SantaMaria
  module Gateway
    class SantaMariaLegacy
      def initialize(endpoint, site_code, language)
        @endpoint = endpoint
        @site_code = site_code
        @language = language
      end

      def all_products
        result = get(URI("#{endpoint}api/products/#{site_code}"))

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
        product = get(URI("#{endpoint}api/products/#{site_code}/#{global_id}"))

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
          variant.version = '0'

          variant
        end
      end

      private

      attr_reader :endpoint, :site_code, :language

      def get(uri)
        request = Net::HTTP::Get.new(uri)
        request['X-Api-Key'] = ENV['SANTA_MARIA_X_API_TOKEN']
        request['accept-language'] = language
        request['accept'] = 'application/json'

        Net::HTTP.start(uri.hostname, 443, use_ssl: true) do |http|
          JSON.parse(http.request(request).body)
        end
      end
    end
  end
end
