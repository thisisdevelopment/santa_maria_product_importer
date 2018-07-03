RSpec.describe SantaMaria::Gateway::SantaMariaLegacy do
  context 'given a product with an id' do
    shared_examples 'santa maria gateway assertions' do
      let(:gateway) { described_class.new(endpoint) }

      before do
        response = {
          products: products.map { |product| product[:basic] }
        }

        stub_request(:get, "#{endpoint}api/products/eukdlx").to_return(
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

      let(:stub_product_get_requests) do
        products.map do |product|
          global_id = product[:basic][:globalId]
          product = product[:basic].merge(product[:extended])

          stub_request(:get, "#{endpoint}api/products/eukdlx/#{global_id}").to_return(
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

          expect(a_request(:get, %r[#{endpoint}api/products/eukdlx/.+])).not_to have_been_requested
        end
      end

      context 'when product variants are accessed' do
        it 'requests product detail from remote service' do
          gateway.all_products { |product| product.variants }

          stub_product_get_requests.each do |request|
            expect(request).to have_been_requested
          end
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

    shared_examples 'santa maria gateway' do
      context do
        let(:endpoint) { 'https://api/' }

        include_examples 'santa maria gateway assertions'
      end

      context do
        let(:endpoint) { 'https://abd/' }

        include_examples 'santa maria gateway assertions'
      end
    end

    context do
      let(:products) do
        [
          {
            basic: {
              globalId: '912817261',
              productType: 'Other',
              name: 'Easycare',
              uriFriendlyName: 'easy-care',
              localSlogan: 'Easycare works really well!',
              packshots: {
                m: 'https://packshots/912817261.jpg'
              }
            },
            extended: {
              packages: []
            }
          },
          {
            basic: {
              globalId: '128371273',
              productType: 'Primer',
              name: 'Weathershield',
              uriFriendlyName: 'weather-shield',
              localSlogan: 'Weathershield is super tough',
              packshots: {}
            },
            extended: {
              packages: [
                {
                  articleNumber: '9281727',
                  price: '19.29',
                  colorTranslation: 'Pure Brilliant Teal',
                  validEcomData: true,
                  colorId: '1827162',
                  friendlyPackSize: '5L',
                  patternId: 'square-print',
                  EANCode: '92817271827162',
                  readyForSale: true,
                  tintedOrReadyMix: 'Tinted'
                },
                {
                  articleNumber: '1821122',
                  price: '39.24',
                  colorTranslation: 'Pure Brilliant Green',
                  validEcomData: false,
                  colorId: '9122162',
                  friendlyPackSize: '2.5L',
                  patternId: 'triangle-print',
                  EANCode: '1010101010101010',
                  readyForSale: false,
                  tintedOrReadyMix: 'ReadyMix'
                }
              ]
            }
          },
          {
            basic: {
              globalId: '91982371',
              productType: 'Primer',
              name: 'Weathershield Pro',
              uriFriendlyName: 'weather-shield-pro',
              localSlogan: 'Weathershield PRO is super tough'
            },
            extended: {
              packages: [
                {
                  articleNumber: '92817271',
                  price: '19.29',
                  colorTranslation: 'Pure Brilliant Teal',
                  validEcomData: true,
                  colorId: '1827162',
                  friendlyPackSize: '5L',
                  patternId: 'square-print',
                  EANCode: '92817271827162',
                  readyForSale: true,
                  tintedOrReadyMix: 'Tinted'
                },
                {
                  articleNumber: '18211221',
                  price: '19.29',
                  colorTranslation: 'Pure Brilliant Teal',
                  validEcomData: true,
                  colorId: '1827162',
                  friendlyPackSize: '5L',
                  patternId: 'square-print',
                  EANCode: '92817271827162',
                  readyForSale: true,
                  tintedOrReadyMix: 'Not Applicable'
                }
              ]
            }
          }
        ]
      end

      let(:expected_products) do
        [
          {
            global_id: '912817261',
            type: 'Other',
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
                version: '0'
              },
              {
                article_number: '1821122',
                price: '39.24',
                valid: false,
                on_sale: false,
                color_id: '9122162',
                ready_mix: true,
                pack_size: '2.5L',
                pattern: 'triangle-print',
                ean: '1010101010101010',
                name: 'Pure Brilliant Green',
                version: '0'
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
                price: '19.29',
                valid: true,
                on_sale: true,
                color_id: '1827162',
                ready_mix: false,
                pack_size: '5L',
                pattern: 'square-print',
                ean: '92817271827162',
                name: 'Pure Brilliant Teal',
                version: '0'
              },
              {
                article_number: '18211221',
                price: '19.29',
                valid: true,
                on_sale: true,
                color_id: '1827162',
                ready_mix: true,
                pack_size: '5L',
                pattern: 'square-print',
                ean: '92817271827162',
                name: 'Pure Brilliant Teal',
                version: '0'
              }
            ]
          }
        ]
      end

      it_behaves_like 'santa maria gateway'
    end
  end
end
