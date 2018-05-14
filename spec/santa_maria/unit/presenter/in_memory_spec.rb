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

  describe '#product' do
    it { is_expected.to respond_to(:product) }
  end

  describe '#variant' do
    it { is_expected.to respond_to(:variant) }
  end
end
