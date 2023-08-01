# frozen_string_literal: true

module Dashboard
  class PromptingPlansController < Dashboard::ApplicationController
    before_action :set_plan, only: %i[show edit update destroy]
    before_action :ensure_owner!, except: %i[index new create]

    def index
      @prompting_plans = PromptingPlan.where(user: current_user).page(params[:page]).per(params[:per_page])
    end

    def show
      redirect_to dashboard_prompting_plan_prompt_elements_url(@prompting_plan), status: :see_other
    end

    def new
      @prompting_plan = PromptingPlan.new
    end

    def edit
    end

    def create
      @prompting_plan = PromptingPlan.new(plan_params)
      @prompting_plan.user = current_user

      if @prompting_plan.save
        flash[:notice] = "Plan was successfully created."
        redirect_to dashboard_prompting_plan_url(@prompting_plan)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @prompting_plan.update(plan_params)
        flash[:notice] = "Plan was successfully updated."
        redirect_to dashboard_prompting_plan_url(@prompting_plan), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @prompting_plan.destroy!

      flash[:notice] = "Plan was successfully destroyed."
      redirect_to dashboard_prompting_plans_url, status: :see_other
    end

    private
      def ensure_owner!
        if @prompting_plan.user != current_user
          flash[:alert] = "You have no permission."
          redirect_back fallback_location: dashboard_prompting_plans_url, status: :see_other
        end
      end

      def set_plan
        @prompting_plan = PromptingPlan.find(params[:id])
      end

      def plan_params
        params.require(:prompting_plan).permit(
          :name,
          :sd_model_name,
          :sampler_name,
          :width,
          :height,
          :fixed_seed,
          :min_steps,
          :max_steps,
          :min_cfg_scale,
          :max_cfg_scale,
          :hires_fix,
          :hires_fix_upscaler_name,
          :hires_fix_upscale,
          :hires_fix_min_steps,
          :hires_fix_max_steps,
          :hires_fix_min_denoising,
          :hires_fix_max_denoising
        )
      end
  end
end
