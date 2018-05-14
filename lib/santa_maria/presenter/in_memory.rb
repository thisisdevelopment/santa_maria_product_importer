module SantaMaria
  module Presenter
    class InMemory
      attr_accessor :products

      def initialize
        @products = []
      end

      def product(id:, type:, name:, uri_name:, description:, image_url:)
        product = {
          id: id,
          type: type,
          name: name,
          uri_name: uri_name,
          description: description,
          image_url: image_url
        }

        products << product
        product
      end

      def variant
      end
    end
  end
end
