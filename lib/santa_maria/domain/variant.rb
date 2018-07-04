module SantaMaria
  module Domain
    class Variant
      attr_accessor :article_number,
                    :price,
                    :color_id,
                    :pack_size,
                    :pattern,
                    :ean,
                    :name,
                    :version,
                    :tinting_id

      attr_writer :valid,
                  :on_sale,
                  :ready_mix

      def valid?
        @valid
      end

      def on_sale?
        @on_sale
      end

      def ready_mix?
        @ready_mix
      end
    end
  end
end
