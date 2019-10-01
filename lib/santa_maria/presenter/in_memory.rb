module SantaMaria
  module Presenter
    class InMemory
      attr_accessor :products, :colors

      def initialize
        @products = []
        @colors = []
      end

      def product(id:, type:, defaultType:, name:, uri_name:, description:, image_url:)
        product = {
          id: id,
          type: type,
          defaultType: defaultType,
          name: name,
          uri_name: uri_name,
          description: description,
          image_url: image_url,
          variants: []
        }

        products << product

        product
      end

      def variant(id:, article_number:, price:, valid:, on_sale:, color_id:,
                  ready_mix:, pack_size:, pattern:, ean:, name:, version:,
                  tinting_id:)
        product = products.detect { |p| p[:id] == id }
        variant = {
          article_number: article_number,
          price: price,
          valid: valid,
          on_sale: on_sale,
          color_id: color_id,
          ready_mix: ready_mix,
          pack_size: pack_size,
          pattern: pattern,
          ean: ean,
          name: name,
          version: version,
          tinting_id: tinting_id
        }

        product[:variants] << variant

        variant
      end

      def color(collection_color_id:, collection_id:, global_color_id:, rgb:,
                color_number:, default_color_number:, color_name:, default_color_name:)
        colors << {
          collection_color_id: collection_color_id,
          collection_id: collection_id,
          global_color_id: global_color_id,
          rgb: rgb,
          color_number: color_number,
          default_color_number: default_color_number,
          color_name: color_name,
          default_color_name: default_color_name
        }
      end
    end
  end
end
