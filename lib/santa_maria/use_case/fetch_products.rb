module SantaMaria
  module UseCase
    class FetchProducts
      def initialize(santa_maria:)
        @santa_maria = santa_maria
      end

      def execute(presenter)
        santa_maria.all_products do |product|
          presenter.product({ id: product.global_id })

          product.variants.each do |variant|
            presenter.variant({ article_number: variant.article_number })
          end
        end
      end

      private

      attr_reader :santa_maria
    end
  end
end
