RSpec.describe SantaMaria::UseCase::FetchColors do
  class SantaMariaStub
    attr_accessor :colors

    def all_colors
      colors
    end
  end

  context do
    let(:presenter) do
      double(
        color: nil
      )
    end

    subject do
      santa_maria = SantaMariaStub.new
      santa_maria.colors = colors

      described_class.new(santa_maria: santa_maria)
    end

    context 'given two colors' do
      let(:colors) { [] }

      before do
        colors << double(
          color_id: '2',
          rgb: 'FFBBEE'
        )
        colors << double(
          color_id: '3',
          rgb: 'rgbrgb',
        )
      end

      it 'calls the presenter with the colors' do
        subject.execute(presenter: presenter)

        expect(presenter).to(
          have_received(:color)
            .with(
              id: '2',
              rgb: 'FFBBEE'
            )
        )
        expect(presenter).to(
          have_received(:color)
            .with(
              id: '3',
              rgb: 'rgbrgb'
            )
        )
      end
    end
  end
end
