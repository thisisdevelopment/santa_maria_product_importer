RSpec.describe SantaMaria::UseCase::FetchProducts do
  class ProductStub
    attr_accessor :global_id, :sku
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
          description: 'Easier than 1-2-3',
          image_url: 'https://packshots/easy-care-123.jpg',
          variants: [
            double(
              article_number: '581239',
              price: '1.00',
              valid?: true,
              on_sale?: false,
              color_id: '1119298',
              ready_mix?: false,
              pack_size: '5L',
              pattern: '',
              ean: 'ANEAN',
              name: 'Green'
            ),
            double(
              article_number: '182356',
              price: '1381.21',
              valid?: true,
              on_sale?: true,
              color_id: '',
              ready_mix?: true,
              pack_size: '2.5L',
              pattern: 'weather-stripes',
              ean: '1928172376162',
              name: 'Teal'
            ),
          ]
        )
        products << double(
          global_id: '3',
          type: 'Paint',
          name: 'Weathershield',
          uri_name: 'weather-shield',
          description: 'More shielding than the Star Ship Enterprise',
          image_url: nil,
          variants: [
            double(
              article_number: '192817',
              price: '1381.21',
              valid?: true,
              on_sale?: true,
              color_id: '2376162',
              ready_mix?: true,
              pack_size: '2.5L',
              pattern: 'weather-stripes',
              ean: '1928172376162',
              name: 'Orange'
            ),
            double(
              article_number: '192811',
              price: '1.00',
              valid?: true,
              on_sale?: false,
              color_id: '1119298',
              ready_mix?: false,
              pack_size: '5L',
              pattern: nil,
              ean: '',
              name: 'Red'
            ),
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
              uri_name: 'easy-care',
              description: 'Easier than 1-2-3',
              image_url: 'https://packshots/easy-care-123.jpg'
            ).ordered
        )
        expect(presenter).to(
          have_received(:product)
            .with(
              id: '3',
              type: 'Paint',
              name: 'Weathershield',
              uri_name: 'weather-shield',
              description: 'More shielding than the Star Ship Enterprise',
              image_url: nil
            ).ordered
        )

        expect(presenter).to(
          have_received(:variant)
            .with(
              id: '2',
              article_number: '581239',
              price: '1.00',
              valid: true,
              on_sale: false,
              color_id: '1119298',
              ready_mix: false,
              pack_size: '5L',
              pattern: nil,
              ean: 'ANEAN',
              name: 'Green'
            ).ordered
        )
        expect(presenter).to(
          have_received(:variant)
            .with(
              id: '2',
              article_number: '182356',
              price: '1381.21',
              valid: true,
              on_sale: true,
              color_id: nil,
              ready_mix: true,
              pack_size: '2.5L',
              pattern: 'weather-stripes',
              ean: '1928172376162',
              name: 'Teal'
            ).ordered
        )
        expect(presenter).to(
          have_received(:variant)
            .with(
              id: '3',
              article_number: '192817',
              price: '1381.21',
              valid: true,
              on_sale: true,
              color_id: '2376162',
              ready_mix: true,
              pack_size: '2.5L',
              pattern: 'weather-stripes',
              ean: '1928172376162',
              name: 'Orange'
            ).ordered
        )
        expect(presenter).to(
          have_received(:variant)
            .with(
              id: '3',
              article_number: '192811',
              price: '1.00',
              valid: true,
              on_sale: false,
              color_id: '1119298',
              ready_mix: false,
              pack_size: '5L',
              pattern: nil,
              ean: nil,
              name: 'Red'
            ).ordered
        )
      end
    end
  end
end
