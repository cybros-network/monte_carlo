# frozen_string_literal: true

module Dashboard::Glossaries
  class VocabulariesController < Dashboard::Glossaries::ApplicationController
    before_action :set_vocabulary, only: %i[destroy]

    def index
      @vocabularies = @glossary.vocabularies
    end

    def create
      @vocabulary = @glossary.vocabularies.build(vocabulary_params)

      if @vocabulary.save
        # flash[:notice] = "Vocabulary was successfully created."
        redirect_to dashboard_glossary_vocabularies_url(@glossary)
      else
        flash[:alert] = "Vocabulary fails to add."
        redirect_to dashboard_glossary_vocabularies_url(@glossary)
      end
    end

    def import
      texts = params[:comma_separated_text].to_s.split(",").filter_map(&:strip)
      # This skip uniqueness check
      # @glossary.vocabularies.insert_all(
      #   texts.map { |text| { text: text } }
      # )
      texts.each do |text|
        @glossary.vocabularies.create text: text
      end
      redirect_to dashboard_glossary_vocabularies_url(@glossary)
    end

    def destroy
      @vocabulary.destroy!

      redirect_to dashboard_glossary_vocabularies_url(@glossary), status: :see_other
    end

    private
      def set_vocabulary
        @vocabulary = @glossary.vocabularies.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def vocabulary_params
        params.require(:vocabulary).permit(:text)
      end
  end
end
