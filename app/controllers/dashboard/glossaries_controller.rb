# frozen_string_literal: true

module Dashboard
  class GlossariesController < Dashboard::ApplicationController
    before_action :set_glossary, only: %i[show edit update destroy]
    before_action :ensure_owner!, except: %i[index new create]

    def index
      @glossaries = Glossary.where(user: current_user).page(params[:page]).per(params[:per_page])
    end

    def show
      redirect_to dashboard_glossary_vocabularies_url(@glossary), status: :see_other
    end

    def new
      @glossary = Glossary.new
    end

    def edit
    end

    def create
      @glossary = Glossary.new(glossary_params)
      @glossary.user = current_user

      if @glossary.save
        flash[:notice] = "Glossary was successfully created."
        redirect_to dashboard_glossary_url(@glossary)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @glossary.update(glossary_params)
        flash[:notice] = "Glossary was successfully updated."
        redirect_to dashboard_glossary_url(@glossary), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @glossary.destroy!

      flash[:notice] = "Glossary was successfully destroyed."
      redirect_to dashboard_glossaries_url, status: :see_other
    end

    private
      def ensure_owner!
        if @glossary.user != current_user
          flash[:alert] = "You have no permission."
          redirect_back fallback_location: dashboard_glossaries_url, status: :see_other
        end
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_glossary
        @glossary = Glossary.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def glossary_params
        params.require(:glossary).permit(:name, :description)
      end
  end
end
