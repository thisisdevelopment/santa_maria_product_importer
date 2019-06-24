require 'json'
require 'net/http'

module SantaMaria
  module Gateway
    class SantaMariaV2
      def initialize(endpoint, domaincode, language, version = nil)
        @endpoint = endpoint
        @domaincode = domaincode
        @language = language
        @version = version
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

              color['colorCollectionColors'].each do |color_collection_color|
                variant = new_variant(sku)
                variant.name = color_collection_color['colorTranslation']
                variant.color_id = color_collection_color['colorCollectionColorID']
                variants << variant
              end

            end
          end
        end

        variants
      end

      def all_colors
        response_colors = get(URI("#{endpoint}api/v2/colors"))['colors']
        response_colors.map do |global_color|
          global_color['colorCollections'].map do |color_collection|
            new_color(global_color['rgb'], color_collection['colorCollectionColorId'])
          end
        end.flatten
      end

      private

      attr_reader :endpoint, :domaincode, :language, :version

      def get(uri)
        http = nil
        request = nil
        tries = 0

        begin
          unless request
            request = Net::HTTP::Get.new(uri)
            request['X-Api-Key'] = ENV['SANTA_MARIA_X_API_TOKEN']
            request['accept-language'] = language
            request['content-type'] = 'application/json'
            request['channel'] = 'flourishweb'
            request['domaincode'] = domaincode
            request['version'] = version unless version.nil?
          end

          unless http
            # puts "Opening connection"
            http = Net::HTTP.start(uri.host, 443, use_ssl: true)
          end

          response = http.request(request)
          result = JSON.parse(response.body)

          raise result['error'] unless result['error'].nil?

          return result

        rescue StandardError => e
          if (tries += 1) <= 10
            # puts "Error getting data from Santa Maria: #{e.to_s}"
            # puts "retrying in #{tries} second(s)..."
            sleep(tries)
            retry
          else
            raise
          end
        ensure
          if http
            # puts "Closing connection"
            http.finish
          end
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
        variant.valid = sku['validEcomData'] == 'true' unless sku['validEcomData'].nil?
        variant.on_sale = sku['readyForSale'] == 'true' unless sku['readyForSale'].nil?
        variant.ready_mix = !['Tinted', 'Basepaint'].include?(sku['tintedOrReadyMix'])
        variant.version = '2'
        variant.tinting_id = sku.dig('genericTintingId')
        variant
      end

      def new_color(rgb, color_collection_color_id)
        color = SantaMaria::Domain::Color.new
        color.color_id = color_collection_color_id
        color.rgb = rgb
        color
      end
    end
  end
end
