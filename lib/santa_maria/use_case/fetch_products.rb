module SantaMaria
  module UseCase
    class FetchProducts
      def initialize(santa_maria:)
        @santa_maria = santa_maria
      end

      def execute(presenter:)
        products = []

        santa_maria.all_products do |product|
          presenter.product(
            id: product.global_id,
            type: product.type,
            name: product.name,
            uri_name: product.uri_name,
            description: product.description,
            image_url: product.image_url
          )

          products << product
        end

        products.each do |product|
          product.variants.each do |variant|
            presenter.variant(
              id: product.global_id,
              article_number: variant.article_number,
              price: variant.price,
              valid: variant.valid?,
              on_sale: variant.on_sale?,
              color_id: variant.color_id == '' ? nil : variant.color_id,
              ready_mix: variant.ready_mix?,
              pack_size: variant.pack_size,
              pattern: variant.pattern == '' ? nil : variant.pattern,
              ean: variant.ean == '' ? nil : variant.ean,
              name: variant.name,
              version: variant.version
            )
          end
        end

        {}
      end

      private

      attr_reader :santa_maria
    end
  end
end
