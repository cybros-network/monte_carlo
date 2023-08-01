# frozen_string_literal: true

module Dashboard::PromptingPlans
  class PromptElementsController < Dashboard::PromptingPlans::ApplicationController
    before_action :set_prompt_element, only: %i[update destroy]

    def index
      @prompt_elements = @prompting_plan.prompt_elements.includes(:glossary)
    end

    def create
      type =
        case params[:_type]
        when "Vocabulary"
          VocabularyPromptElement
        when "Glossary"
          GlossaryPromptElement
        else
          redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan)
        end
      @prompt_element = @prompting_plan.prompt_elements.build(type: type)
      @prompt_element.assign_attributes prompt_element_params

      if @prompt_element.save
        # flash[:notice] = "Prompt element was successfully created."
        redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan)
      else
        flash[:alert] = "Prompt element fails to add."
        redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan)
      end
    end

    def update
      if @prompt_element.update(prompt_element_params)
        flash[:notice] = "Prompt element was successfully updated."
        redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan), status: :see_other
      else
        flash[:alert] = "Prompt element fails to update."
        redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan)
      end
    end

    def destroy
      @prompt_element.destroy!

      redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan), status: :see_other
    end

    private
      def set_prompt_element
        @prompt_element = @prompting_plan.prompt_elements.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def prompt_element_params
        params.require(:prompt_element).permit(
          :negative,
          :text,
          :glossary_id,
          :frequency
        )
      end
  end
end
