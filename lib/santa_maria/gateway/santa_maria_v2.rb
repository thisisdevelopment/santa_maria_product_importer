require 'json'
require 'net/http'

module SantaMaria
  module Gateway
    class SantaMariaV2
      def initialize(endpoint, domaincode, language)
        @endpoint = endpoint
        @domaincode = domaincode
        @language = language
      end

      def all_products
        uri = URI("#{endpoint}api/v2/products")

        result = get(uri)

        result['products'].each do |product|
          yield new_product(product)
        end
      end

      def variants_for(global_id)
        uri = URI("#{endpoint}api/v2/products/#{global_id}")

        product = get(uri)

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

      def all_colors
        response_colors = get(URI("#{endpoint}api/v2/colors"))['colors']
        response_colors.map do |response_color|
          new_color(response_color)
        end
      end

      private

      attr_reader :endpoint, :domaincode, :language

      def get(uri)
        request = Net::HTTP::Get.new(uri)
        request['X-Api-Key'] = ENV['SANTA_MARIA_X_API_TOKEN']
        request['accept-language'] = language
        request['content-type'] = 'application/json'
        request['channel'] = 'flourishweb'
        request['domaincode'] = domaincode

        Net::HTTP.start(uri.hostname, 443, use_ssl: true) do |http|
          JSON.parse(http.request(request).body)
        end
      end

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

      def new_color(color_data)
        color = SantaMaria::Domain::Color.new
        color.color_id = color_data['colorId']
        color.rgb = color_data['rgb']
        color
      end
    end
  end
end
