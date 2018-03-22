RSpec.describe SantaMaria::Gateway::SantaMariaV2 do
  let(:endpoint) { "http://api-aroo/"}
  let(:gateway) { described_class.new(endpoint) }

  before do
    response = {
      products: products.map { |product| product[:basic] }
    }

    stub_request(:get, "#{endpoint}api/v2/products").to_return(
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

          stub_request(:get, "#{endpoint}api/v2/products/#{global_id}").to_return(
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
              localSlogan: 'Easycare works really well!',
              packshots: [{ m: 'https://packshots/912817261.jpg' }]
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
              localSlogan: 'Weathershield is super tough',
              packshots: [{}]
            },
            extended: {
              sku: [
                {
                  articleNumber: '9281727',
                  price: '19.29',
                  validEcomData: true,
                  readyForSale: true,
                  colorIds: [
                    {
                      colorCollectionColors: [
                        {
                          colorCollectionColorID: '1827162',
                          colorTranslation: 'Pure Brilliant Teal'
                        }
                      ]
                    }
                  ],
                  tintedOrReadyMix: 'Tinted',
                  friendlyPackSizeTranslation: '5L',
                  pattern: [
                    {
                      name: 'square-print'
                    }
                  ],
                  eanCode: '92817271827162'
                },
                {
                  articleNumber: '1821122',
                  price: '21.39',
                  validEcomData: true,
                  readyForSale: true,
                  tintedOrReadyMix: 'Not Applicable',
                  friendlyPackSizeTranslation: '5L',
                  eanCode: '22222221827162'
                }
              ]
            }
          },
          {
            basic: {
              globalId: '91982371',
              productType: 'Primer',
              name: 'Weathershield Pro',
              uri: 'weather-shield-pro',
              localSlogan: 'Weathershield PRO is super tough'
            },
            extended: {
              sku: [
                {
                  articleNumber: '92817271',
                  price: '19.20',
                  colorIds: [
                    {
                      colorCollectionColors: [
                        {
                          colorCollectionColorID: '1827162',
                          colorTranslation: 'Pure Brilliant Red'
                        }
                      ]
                    },
                    {
                      colorCollectionColors: [
                        {
                          colorCollectionColorID: '1000001',
                          colorTranslation: 'Pure Brilliant Green'
                        }
                      ]
                    }
                  ]
                },
                { articleNumber: '18211221' }
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
            image_url: 'https://packshots/912817261.jpg',
            variants: []
          },
          {
            global_id: '128371273',
            type: 'Primer',
            name: 'Weathershield',
            uri_name: 'weather-shield',
            description: 'Weathershield is super tough',
            image_url: nil,
            variants: [
              {
                article_number: '9281727',
                price: '19.29',
                valid: true,
                on_sale: true,
                color_id: '1827162',
                ready_mix: false,
                pack_size: '5L',
                pattern: 'square-print',
                ean: '92817271827162',
                name: 'Pure Brilliant Teal'
              },
              {
                article_number: '1821122',
                price: '21.39',
                valid: true,
                on_sale: true,
                color_id: nil,
                ready_mix: true,
                pack_size: '5L',
                pattern: nil,
                ean: '22222221827162',
                name: nil
              }
            ]
          },
          {
            global_id: '91982371',
            type: 'Primer',
            name: 'Weathershield Pro',
            uri_name: 'weather-shield-pro',
            description: 'Weathershield PRO is super tough',
            image_url: nil,
            variants: [
              {
                article_number: '92817271',
                price: '19.20',
                ready_mix: true,
                color_id: '1827162',
                name: 'Pure Brilliant Red'
              },
              {
                article_number: '92817271',
                price: '19.20',
                ready_mix: true,
                color_id: '1000001',
                name: 'Pure Brilliant Green'
              },
              { article_number: '18211221', ready_mix: true }
            ]
          }
        ]
      end
      context 'example 1' do
        let(:endpoint) {'http://api-santamaria'}

        it_behaves_like 'santa maria gateway'
      end

      context 'example 2' do
        let(:endpoint) {'http://api'}

        it_behaves_like 'santa maria gateway'
      end
    end
  end
end
