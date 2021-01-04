module V2
  class DigitalContentsController < BaseController

    def index
      documents = prismic.query(Prismic::Predicates.at("document.type", "cosmic_therapy_video")).results

      @videos = documents.map do |document|
        OpenStruct.new(
          id: document.id,
          title: document['cosmic_therapy_video.title'].as_text,
          image: document['cosmic_therapy_video.image']&.url || 'v2/video-img.jpg'
        )
      end
    end

    def show
      document = prismic.getByID params[:id]
      @src = document['cosmic_therapy_video.jw_player_link'].url
      @div_id = "botr_#{@src.rpartition('/').last.split('.').first.gsub('-', '_')}_div"
    end

    private

    def prismic
      Prismic.api ENV['PRISMIC_URL'], ENV['PRISMIC_TOKEN']
    end

  end
end
