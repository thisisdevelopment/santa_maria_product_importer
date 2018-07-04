RSpec.describe SantaMaria::Gateway::SantaMariaV2 do
  let(:endpoint) { "https://api-aroo/"}
  let(:domaincode) { 'eukdlx' }
  let(:language) { 'en' }
  let(:gateway) { described_class.new(endpoint, domaincode, language) }
  let(:token) { 'somefaketoken' }
  let(:products) { [] }

  before do
    response = {
      products: products.map { |product| product[:basic] }
    }

    ENV['SANTA_MARIA_X_API_TOKEN'] = token

    stub_request(:get, "#{endpoint}api/v2/products")
    .with(
      headers: {
        'Accept-Language' => language,
        'Channel' => 'flourishweb',
        'Domaincode' => domaincode,
        'X-Api-Key' => token
      }
    )
    .to_return(
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

          stub_request(:get, "#{endpoint}api/v2/products/#{global_id}").with(
            headers: {
              'Accept-Language' => language,
              'Channel' => 'flourishweb',
              'Domaincode' => domaincode,
              'X-Api-Key' => token
            }
          ).to_return(
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
                  validEcomData: 'true',
                  readyForSale: 'true',
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
                  eanCode: '92817271827162',
                  genericTintingId: '9998887'
                },
                {
                  articleNumber: '1821122',
                  price: '21.39',
                  validEcomData: 'true',
                  readyForSale: 'true',
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
                          colorCollectionColorID: '1186982',
                          colorTranslation: 'NORDIC SAILS 2'
                        },
                        {
                          colorCollectionColorID: '1811241',
                          colorTranslation: 'Heart Wood'
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
                name: 'Pure Brilliant Teal',
                version: '2',
                tinting_id: '9998887'
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
                name: nil,
                version: '2',
                tinting_id: nil
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
                name: 'Pure Brilliant Red',
                version: '2',
                tinting_id: nil
              },
              {
                article_number: '92817271',
                price: '19.20',
                ready_mix: true,
                color_id: '1186982',
                name: 'NORDIC SAILS 2',
                version: '2',
                tinting_id: nil
              },
              {
                article_number: '92817271',
                price: '19.20',
                ready_mix: true,
                color_id: '1811241',
                name: 'Heart Wood',
                version: '2',
                tinting_id: nil
              },
              { article_number: '18211221', ready_mix: true, version: '2' }
            ]
          }
        ]
      end
      context 'example 1' do
        let(:endpoint) {'https://api-santamaria'}
        let(:domaincode) { 'eukdlx' }
        let(:language) { 'en' }

        it_behaves_like 'santa maria gateway'
      end

      context 'example 2' do
        let(:endpoint) {'https://api'}
        let(:domaincode) { 'ebelev' }
        let(:language) { 'nl' }

        it_behaves_like 'santa maria gateway'
      end
    end
  end

  context 'color api' do
    before do
      response = {
        colors: api_colors_response
      }

      stub_request(:get, "#{endpoint}api/v2/colors").with(
        headers: {
          'Accept-Language' => language,
          'Channel' => 'flourishweb',
          'Domaincode' => domaincode,
          'X-Api-Key' => token
        }
      ).to_return(
        body: response.to_json,
        status: 200
      )
    end

    context 'no colors' do
      let(:api_colors_response) { [] }

      it 'returns an empty array' do
        expect(gateway.all_colors).to eq([])
      end
    end

    context 'two global colors, each with two color collection ids each' do
      let(:api_colors_response) do
        [
          {
            colorId: "10",
            rgb: "B1AFB1",
            colorCollections: [
              {
                colorCollectionColorId: "1032530",
              },
              {
                colorCollectionColorId: "2032550"
              }
            ]
          },
          {
            colorId: "1032534",
            rgb: "A1AD62",
            colorCollections: [
              {
                colorCollectionColorId: "3032510",
              },
              {
                colorCollectionColorId: "4032520"
              }
            ]

          }
        ]
      end

      let(:expected_colors) do
        [
          {
            color_id: "1032530",
            rgb: "B1AFB1",
          },
          {
            color_id: "2032550",
            rgb: "B1AFB1"
          },
          {
            color_id: "3032510",
            rgb: "A1AD62"
          },
          {
            color_id: "4032520",
            rgb: "A1AD62"
          }
        ]
      end

      it 'flattens each color collection color id with its rgb value' do
        expected = expected_colors.map do |expected_color|
          a_color(expected_color)
        end

        expect { |block| gateway.all_colors.each(&block) }.to (
          yield_successive_args(*expected)
        )
      end
    end
  end
end
