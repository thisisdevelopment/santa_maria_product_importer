RSpec.describe SantaMaria::Presenter::InMemory do
  let(:product_data) do
    {
      id: 1,
      type: 'paint',
      name: 'purple party',
      uri_name: 'example.com/tagine',
      description: 'this paint is the best',
      image_url: 'imagehost.com/evs'
    }
  end

  let(:variant_data) do
    {
      id: 1,
      article_number: '1234',
      price: '2.99',
      valid: true,
      on_sale: false,
      color_id: '5678',
      ready_mix: true,
      pack_size: 'm',
      pattern: '',
      ean: '9900990099',
      name: 'Red'
    }
  end

  describe '#product' do
    before do
      subject.product(product_data)
    end

    it 'sets variants to empty array when no variant presenter method called' do
      expect(subject.products[0][:variants]).to eq([])
    end

    it 'keeps products in the memory' do
      expect(subject.products).to eq([product_data.merge(variants: [])])
    end
  end

  describe '#variant' do
    it 'assigns the variant underneath its product' do
      subject.product(product_data)
      subject.variant(variant_data)

      variant_data_without_id = variant_data.tap { |h| h.delete(:id) }

      expect(subject.products[0][:variants]).to eq([variant_data_without_id])
    end
  end

  describe '#colors' do
    it 'defaults to empty array' do
      expect(subject.colors).to eq([])
    end

    let(:color) do
      {
        id: '123456',
        rgb: 'FFEEDD'
      }
    end

    it 'appends a color to the colors array' do
      subject.color(color)
      expect(subject.colors).to eq([color])
    end
  end
end
