RSpec.describe SantaMaria::UseCase::FetchProducts do
  class ProductStub
    attr_accessor :global_id, :sku
  end

  class VariantStub
    attr
  end

  class SantaMariaStub
    attr_accessor :products

    def all_products
      products.each do |product|
        yield product
      end
    end
  end

  context do
    let(:presenter) do
      double(
        product: nil,
        variant: nil
      )
    end

    subject do
      santa_maria = SantaMariaStub.new
      santa_maria.products = products

      described_class.new(santa_maria: santa_maria)
    end

    context 'given two products and two variants each' do
      let(:products) { [] }
      before do
        products << double(
          global_id: '2',
          type: 'Other',
          name: 'Easycare',
          uri_name: 'easy-care',
          variants: [
            double(article_number: '581239'),
            double(article_number: '182356'),
          ]
        )
        products << double(
          global_id: '3',
          type: 'Paint',
          name: 'Weathershield',
          uri_name: 'weather-shield',
          variants: [
            double(article_number: '192817'),
            double(article_number: '192811'),
          ]
        )
      end

      it 'exports all products first, then exports variants' do
        subject.execute(presenter)

        expect(presenter).to(
          have_received(:product)
            .with(
              id: '2',
              type: 'Other',
              name: 'Easycare',
              uri_name: 'easy-care'
            ).ordered
        )
        expect(presenter).to(
          have_received(:product)
            .with(
              id: '3',
              type: 'Paint',
              name: 'Weathershield',
              uri_name: 'weather-shield'
            ).ordered
        )

        expect(presenter).to(
          have_received(:variant).with({ id: '2', article_number: '581239'}).ordered
        )
        expect(presenter).to(
          have_received(:variant).with({ id: '2', article_number: '182356' }).ordered
        )
        expect(presenter).to(
          have_received(:variant).with({ id: '3', article_number: '192817' }).ordered
        )
        expect(presenter).to(
          have_received(:variant).with({ id: '3', article_number: '192811' }).ordered
        )
      end
    end
  end
end
