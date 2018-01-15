RSpec.describe 'product catalogue' do
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

  context do
    before do
      stub_request(:get, "https://api/api/v2/products/fb1c568f-2c42-4b7d-8cac-a18500de96e8")
        .to_return(
          body: { sku: [] }.to_json,
          status: 200
        )

      stub_request(:get, "https://api/api/v2/products")
        .to_return(
          body: response.to_json,
          status: 200
        )
    end

    context 'given one product' do
      let(:response) do
        response = {
          products: [{
                       globalId: 'fb1c568f-2c42-4b7d-8cac-a18500de96e8'
                     }]
        }
      end

      it 'it able to extract those products' do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: SantaMaria::Gateway::SantaMariaV2.new('http://api/')
        )

        spy_presenter = SpyPresenter.new
        use_case.execute(spy_presenter)

        expect(spy_presenter.products[0][:id]).to eq('fb1c568f-2c42-4b7d-8cac-a18500de96e8')
        expect(spy_presenter.variants).to eq([])
      end
    end

    context 'given one product with a variant' do
      before do
        stub_request(:get, "https://api/api/v2/products/192871-19291-39192-109283")
          .to_return(
            body: { sku: [{ articleNumber: '1111111' }] }.to_json,
            status: 200
          )
      end

      let(:response) do
        response = {
          products: [{
                       globalId: '192871-19291-39192-109283'
                     }]
        }
      end

      it 'it able to extract those products' do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: SantaMaria::Gateway::SantaMariaV2.new('http://api/')
        )

        spy_presenter = SpyPresenter.new
        use_case.execute(spy_presenter)

        expect(spy_presenter.products[0][:id]).to eq('192871-19291-39192-109283')
        expect(spy_presenter.variants[0][:article_number]).to eq('1111111')
      end
    end
  end
end
