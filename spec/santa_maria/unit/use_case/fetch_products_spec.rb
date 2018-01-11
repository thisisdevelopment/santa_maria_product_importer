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

    shared_examples 'product extractor' do
      let(:products) { [] }

      it 'presents the product' do
        subject.execute(presenter)
        expect(presenter).to have_received(:product).with({ id: expected_global_id })
      end
    end

    context 'given one product with no variants' do
      context do
        before do
          products << double(global_id: '1', variants: [])
        end

        let(:expected_global_id) { '1' }

        it_behaves_like 'product extractor'
      end

      context do
        before do
          products << double(global_id: '2', variants: [])
        end

        let(:expected_global_id) { '2' }

        it_behaves_like 'product extractor'
      end
    end

    shared_examples 'variant extractor' do
      let(:products) { [] }

      it 'presents the variant' do
        subject.execute(presenter)
        expect(presenter).to(
          have_received(:variant).with({ article_number: expected_article_number })
        )
      end
    end

    context 'given one product with one variant' do
      context do
        before do
          products << double(
            global_id: '2',
            variants: [double(article_number: '98271')]
          )
        end

        let(:expected_article_number) { '98271' }

        it_behaves_like 'variant extractor'
      end

      context do
        before do
          products << double(
            global_id: '2',
            variants: [double(article_number: '581239')]
          )
        end

        let(:expected_article_number) { '581239' }

        it_behaves_like 'variant extractor'
      end
    end
  end
end
