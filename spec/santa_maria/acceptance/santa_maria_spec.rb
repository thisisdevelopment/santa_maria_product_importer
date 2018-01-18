RSpec.describe 'santa maria' do
  class SpyPresenter
    attr_reader :products, :variants

    def initialize
      @products = []
      @variants = []
    end

    def product(product)
      @products << product
    end

    def variant(variant)
      @variants << variant
    end
  end

  context 'given two products with a variant' do
    shared_examples 'matches expected product data' do
      let(:spy_presenter) { SpyPresenter.new }

      subject do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: santa_maria
        )

        use_case.execute(presenter: spy_presenter)
      end

      before do
        product_requests
        products_request
        subject
      end

      it 'is able to extract the products' do
        product_1 = spy_presenter.products[0]
        expect(product_1[:id]).to eq('192871-19291-39192-109283')
        expect(product_1[:type]).to eq('Paint')
        expect(product_1[:name]).to eq('Easycare')
        expect(product_1[:uri_name]).to eq('easy-care')
        expect(product_1[:description]).to eq('Dulux easy care...')
        expect(product_1[:image_url]).to eq('https://packshots/easycare.jpg')

        product_2 = spy_presenter.products[1]
        expect(product_2[:id]).to eq('192871-19291-39192-982910')
        expect(product_2[:type]).to eq('Paint')
        expect(product_2[:name]).to eq('Paint Mixing Easycare')
        expect(product_2[:uri_name]).to eq('paint-mixing-easy-care')
        expect(product_2[:description]).to eq('Dulux paint mixing easy care...')
        expect(product_2[:image_url]).to be_nil

        variant_1 = spy_presenter.variants[0]
        expect(variant_1[:id]).to eq('192871-19291-39192-109283')
        expect(variant_1[:article_number]).to eq('1111111')
        expect(variant_1[:price]).to eq('45.80')
        expect(variant_1[:valid]).to eq(true)
        expect(variant_1[:on_sale]).to eq(true)
        expect(variant_1[:color_id]).to eq('2981722')
        expect(variant_1[:ready_mix]).to eq(true)
        expect(variant_1[:pack_size]).to eq('2.5L')
        expect(variant_1[:pattern]).to be_nil
        expect(variant_1[:ean]).to eq('11111112981722')
        expect(variant_1[:name]).to eq('Radioactive Orange')

        variant_2 = spy_presenter.variants[1]
        expect(variant_2[:id]).to eq('192871-19291-39192-982910')
        expect(variant_2[:article_number]).to eq('2222222')
        expect(variant_2[:price]).to eq('19.29')
        expect(variant_2[:valid]).to eq(true)
        expect(variant_2[:on_sale]).to eq(true)
        expect(variant_2[:color_id]).to eq('1827162')
        expect(variant_2[:ready_mix]).to eq(false)
        expect(variant_2[:pack_size]).to eq('2.5L')
        expect(variant_2[:pattern]).to eq('square-print')
        expect(variant_2[:ean]).to eq('22222221827162')
        expect(variant_2[:name]).to eq('Pure Brilliant Red')

        variant_3 = spy_presenter.variants[2]
        expect(variant_3[:id]).to eq('192871-19291-39192-982910')
        expect(variant_3[:article_number]).to eq('3333333')
        expect(variant_3[:price]).to eq('45.80')
        expect(variant_3[:valid]).to eq(false)
        expect(variant_3[:on_sale]).to eq(false)
        expect(variant_3[:ready_mix]).to eq(true)
        expect(variant_3[:pack_size]).to eq('2.5L')
        expect(variant_3[:color_id]).to be_nil
        expect(variant_3[:pattern]).to be_nil
        expect(variant_3[:ean]).to be_nil
        expect(variant_3[:name]).to be_nil
      end
    end

    shared_examples 'product data' do
      context do
        let(:endpoint) { 'https://api/' }

        include_examples 'matches expected product data'
      end

      context do
        let(:endpoint) { 'http://santamaria-api/' }

        include_examples 'matches expected product data'
      end
    end

    describe 'legacy' do
      let(:product_requests) do
        product_1 = {
          packages: [
            {
              articleNumber: '1111111',
              price: '45.80',
              validEcomData: true,
              readyForSale: true,
              colorId: '2981722',
              colorTranslation: 'Radioactive Orange',
              tintedOrReadyMix: 'ReadyMix',
              friendlyPackSize: '2.5L',
              patternId: '',
              EANCode: '11111112981722'
            }
          ]
        }

        product_2 = {
          packages: [
            {
              articleNumber: '2222222',
              price: '19.29',
              validEcomData: true,
              readyForSale: true,
              colorId: '1827162',
              colorTranslation: 'Pure Brilliant Red',
              tintedOrReadyMix: 'Tinted',
              friendlyPackSize: '2.5L',
              patternId: 'square-print',
              EANCode: '22222221827162'
            },
            {
              articleNumber: '3333333',
              price: '45.80',
              validEcomData: false,
              readyForSale: false,
              colorId: '',
              friendlyPackSize: '2.5L',
              EANCode: ''
            }
          ]
        }

        [
          stub_request(:get, "#{endpoint}api/products/eukdlx/192871-19291-39192-109283")
            .to_return(
              body: product_1.to_json,
              status: 200
            ),
          stub_request(:get, "#{endpoint}api/products/eukdlx/192871-19291-39192-982910")
            .to_return(
              body: product_2.to_json,
              status: 200
            ),

        ]
      end

      let(:products_request) do
        response = {
          products: [
            {
              globalId: '192871-19291-39192-109283',
              productType: 'Paint',
              name: 'Easycare',
              uriFriendlyName: 'easy-care',
              localSlogan: 'Dulux easy care...',
              packshots: {
                m: 'https://packshots/easycare.jpg'
              }
            },
            {
              globalId: '192871-19291-39192-982910',
              productType: 'Paint',
              name: 'Paint Mixing Easycare',
              uriFriendlyName: 'paint-mixing-easy-care',
              localSlogan: 'Dulux paint mixing easy care...'
            }
          ]
        }

        stub_request(:get, "#{endpoint}api/products/eukdlx")
          .to_return(
            body: response.to_json,
            status: 200
          )
      end

      let(:santa_maria) do
        SantaMaria::Gateway::SantaMariaLegacy.new(endpoint)
      end

      include_examples 'product data'
    end

    xdescribe 'v2' do
      let(:product_requests) do
        product_1 = {
          sku: [
            {
              articleNumber: '1111111',
              price: '45.80',
              validEcomData: true,
              readyForSale: true,
              colorIds: [
                {
                  colorCollectionColors: [
                    {
                      colorCollectionColorID: '2981722',
                      colorTranslation: 'Radioactive Orange'
                    }
                  ]
                }
              ],
              tintedOrReadyMix: 'ReadyMix',
              friendlyPackSizeTranslation: '2.5L',
              eanCode: '11111112981722'
            }
          ]
        }

        product_2 = {
          sku: [
            {
              articleNumber: '2222222',
              price: '19.29',
              validEcomData: true,
              readyForSale: true,
              colorIds: [
                {
                  colorCollectionColors: [
                    {
                      colorCollectionColorID: '1827162',
                      colorTranslation: 'Pure Brilliant Red'
                    }
                  ]
                }
              ],
              tintedOrReadyMix: 'Tinted',
              friendlyPackSizeTranslation: '2.5L',
              pattern: [
                {
                  name: 'square-print'
                }
              ],
              eanCode: '22222221827162'
            },
            {
              articleNumber: '3333333',
              price: '45.80',
              validEcomData: false,
              readyForSale: false,
              friendlyPackSizeTranslation: '2.5L',
              eanCode: ''
            }
          ]
        }

        [
          stub_request(:get, "#{endpoint}api/v2/products/192871-19291-39192-109283")
            .to_return(
              body: product_1.to_json,
              status: 200
            ),
          stub_request(:get, "#{endpoint}api/v2/products/192871-19291-39192-982910")
            .to_return(
              body: product_2.to_json,
              status: 200
            )
        ]
      end

      let(:products_request) do
        response = {
          products: [
            {
              globalId: '192871-19291-39192-109283',
              productType: 'Paint',
              name: 'Easycare',
              uri: 'easy-care',
              localSlogan: 'Dulux easy care...',
              packshots: [
                {
                  m: 'https://packshots/easycare.jpg'
                }
              ]
            },
            {
              globalId: '192871-19291-39192-982910',
              productType: 'Paint',
              name: 'Paint Mixing Easycare',
              uri: 'paint-mixing-easy-care',
              localSlogan: 'Dulux paint mixing easy care...'
            }
          ]
        }

        stub_request(:get, "#{endpoint}api/v2/products")
          .to_return(
            body: response.to_json,
            status: 200
          )
      end

      let(:santa_maria) do
        SantaMaria::Gateway::SantaMariaV2.new(endpoint)
      end

      include_examples 'product data'
    end
  end
end
