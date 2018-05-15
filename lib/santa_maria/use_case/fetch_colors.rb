module SantaMaria
  module UseCase
    class FetchColors
      def initialize(santa_maria:)
        @santa_maria = santa_maria
      end

      def execute(presenter:)
        santa_maria.all_colors.each do |color|
          presenter.color(
            id: color.color_id,
            rgb: color.rgb,
          )
        end
      end

      private

      attr_reader :santa_maria
    end
  end
end
