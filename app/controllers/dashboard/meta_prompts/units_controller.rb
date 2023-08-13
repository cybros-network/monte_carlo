# frozen_string_literal: true

module Dashboard::MetaPrompts
  class UnitsController < Dashboard::MetaPrompts::ApplicationController
    before_action :set_meta_prompt_unit, only: %i[update destroy]

    def index
      @meta_prompt_units = @meta_prompt.units.includes(:glossary)
    end

    def create
      type =
        case params[:_type]
        when "Vocabulary"
          MetaPromptUnits::Vocabulary
        when "Glossary"
          MetaPromptUnits::Glossary
        else
          redirect_to dashboard_meta_prompt_units_url(@meta_prompt)
          return
        end
      @meta_prompt_unit = @meta_prompt.units.build(type: type)
      @meta_prompt_unit.assign_attributes meta_prompt_unit_params

      if @meta_prompt_unit.save
        # flash[:notice] = "Prompt unit was successfully created."
        redirect_to dashboard_meta_prompt_units_url(@meta_prompt)
      else
        flash[:alert] = "Prompt unit fails to add."
        redirect_to dashboard_meta_prompt_units_url(@meta_prompt)
      end
    end

    def update
      if @meta_prompt_unit.update(meta_prompt_unit_params)
        flash[:notice] = "Prompt unit was successfully updated."
        redirect_to dashboard_meta_prompt_units_url(@meta_prompt), status: :see_other
      else
        flash[:alert] = "Prompt unit fails to update."
        redirect_to dashboard_meta_prompt_units_url(@meta_prompt)
      end
    end

    def destroy
      @meta_prompt_unit.destroy!

      redirect_to dashboard_meta_prompt_units_url(@meta_prompt), status: :see_other
    end

    private
      def set_meta_prompt_unit
        @meta_prompt_unit = @meta_prompt.units.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def meta_prompt_unit_params
        params.require(:meta_prompt_unit).permit(
          :negative,
          :text,
          :glossary_id,
          :frequency
        )
      end
  end
end
