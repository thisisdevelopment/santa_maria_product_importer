RSpec.describe SantaMaria::Gateway::SantaMariaV2 do
  let(:gateway) { described_class.new('https://api/') }

  before do
    response = {
      products: products.map { |product| product[:basic] }
    }

    stub_request(:get, "https://api/api/v2/products").to_return(
      body: response.to_json,
      status: 200
    )
  end

  context 'given no products' do
    let(:products) { [] }

    it 'yields no products' do
      expect { |block| gateway.all_products(&block) }.not_to yield_control
    end
  end

  context 'given a product with an id' do
    shared_examples 'santa maria gateway' do
      let(:stub_product_get_requests) do
        products.map do |product|
          global_id = product[:basic][:globalId]
          product = product[:basic].merge(product[:extended])

          stub_request(:get, "https://api/api/v2/products/#{global_id}").to_return(
            body: product.to_json,
            status: 200
          )
        end
      end

      let!(:stub_product_get) do
        stub_product_get_requests[0]
      end

      context 'when reading all products' do
        it 'yields a product with an id' do
          expected = expected_products.map do |expected_product|
            a_product(expected_product)
          end

          expect { |block| gateway.all_products(&block) }.to(
            yield_successive_args(*expected)
          )
        end

        it 'does not request product detail from remote service' do
          gateway.all_products { |_| }
          expect(stub_product_get).not_to have_been_requested
        end
      end

      context 'when product variants are accessed' do
        it 'requests product detail from remote service' do
          gateway.all_products { |product| product.variants }
          expect(stub_product_get).to have_been_requested
        end

        it 'should yield a product with the correct variants' do
          expected = expected_products.map do |expected_product|
            a_product_with_variants(expected_product[:variants])
          end

          expect { |block| gateway.all_products(&block) }.to(
            yield_successive_args(*expected)
          )
        end
      end
    end

    context do
      let(:products) do
        [
          {
            basic: {
              globalId: '912817261',
              productType: 'Paint',
              name: 'Easycare',
              uri: 'easy-care',
              localSlogan: 'Easycare works really well!'
            },
            extended: {
              sku: []
            }
          },
          {
            basic: {
              globalId: '128371273',
              productType: 'Primer',
              name: 'Weathershield',
              uri: 'weather-shield',
              localSlogan: 'Weathershield is super tough'
            },
            extended: {
              sku: [
                { articleNumber: '9281727' },
                { articleNumber: '1821122' }
              ]
            }
          }
        ]
      end

      let(:expected_products) do
        [
          {
            global_id: '912817261',
            type: 'Paint',
            name: 'Easycare',
            uri_name: 'easy-care',
            description: 'Easycare works really well!',
            variants: []
          },
          {
            global_id: '128371273',
            type: 'Primer',
            name: 'Weathershield',
            uri_name: 'weather-shield',
            description: 'Weathershield is super tough',
            variants: [
              { article_number: '9281727' },
              { article_number: '1821122' }
            ]
          }
        ]
      end

      it_behaves_like 'santa maria gateway'
    end
  end
end
