RSpec.describe SantaMaria::Gateway::SantaMariaV2 do
  let(:gateway) { described_class.new('https://api/') }

  RSpec::Matchers.define :a_product_with_id do |id|
    match { |product| id == product.global_id }
  end

  RSpec::Matchers.define :a_product_with_variant do |expected|
    match do |product|
      matches = product.variants.map do |variant|
        variant.article_number == expected[:article_number]
      end

      matches.include?(true)
    end
  end

  before do
    stub_request(:get, "https://api/api/v2/products").to_return(
      body: response.to_json,
      status: 200
    )
  end

  context 'given no products' do
    let(:response) do
      {
        products: []
      }
    end

    it 'yields no products' do
      expect { |block| gateway.all_products(&block) }.not_to yield_control
    end
  end

  context 'given a product with an id' do
    shared_examples 'santa maria gateway' do
      let(:response) do
        {
          products: [{
                       globalId: global_id
                     }]
        }
      end

      let!(:stub_product_get) do
        product = {
          sku: [
            {
              articleNumber: article_number
            }
          ]
        }

        stub_request(:get, "https://api/api/v2/products/#{global_id}").to_return(
          body: product.to_json,
          status: 200
        )
      end

      context 'when reading all products' do
        it 'yields a product with an id' do
          expect { |block| gateway.all_products(&block) }.to(
            yield_with_args(a_product_with_id(global_id))
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

        it 'should yield a product with a variant' do
          expect { |block| gateway.all_products(&block) }.to(
            yield_with_args(a_product_with_variant(article_number: article_number))
          )
        end
      end
    end

    context do
      let(:global_id) { '19281811918' }
      let(:article_number) { '1923810' }

      it_behaves_like 'santa maria gateway'
    end

    context do
      let(:global_id) { '912817261' }
      let(:article_number) { '5819281' }

      it_behaves_like 'santa maria gateway'
    end
  end
end
