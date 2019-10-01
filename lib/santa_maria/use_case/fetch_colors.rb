module SantaMaria
  module UseCase
    class FetchColors
      def initialize(santa_maria:)
        @santa_maria = santa_maria
      end

      def execute(presenter:)
        santa_maria.all_colors.each do |color|
          presenter.color(
            collection_color_id: color.collection_color_id,
            collection_id: color.collection_id,
            global_color_id: color.global_color_id,
            rgb: color.rgb,
            color_number: color.color_number,
            default_color_number: color.default_color_number,
            color_name: color.color_name,
            default_color_name: color.default_color_name
          )
        end
      end

      private

      attr_reader :santa_maria
    end
  end
end
