module SantaMaria
  module Domain
    class Product
      attr_accessor :global_id, :type, :name, :uri_name, :description, :image_url

      def initialize(variant_accessor)
        @variant_accessor = variant_accessor
      end

      def variants
        @variant_accessor.variants_for(global_id)
      end
    end
  end
end
