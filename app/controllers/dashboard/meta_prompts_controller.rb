# frozen_string_literal: true

module Dashboard
  class MetaPromptsController < Dashboard::ApplicationController
    before_action :set_meta_prompt, only: %i[show edit update destroy]
    before_action :ensure_owner!, except: %i[index new create]

    def index
      @meta_prompts = MetaPrompt.where(user: current_user).page(params[:page]).per(params[:per_page])
    end

    def show
      redirect_to dashboard_meta_prompt_units_url(@meta_prompt), status: :see_other
    end

    def new
      @meta_prompt = MetaPrompt.new
    end

    def edit
    end

    def create
      @meta_prompt = MetaPrompt.new(meta_prompt_params)
      @meta_prompt.user = current_user

      if @meta_prompt.save
        flash[:notice] = "Plan was successfully created."
        redirect_to dashboard_meta_prompt_url(@meta_prompt)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @meta_prompt.update(meta_prompt_params)
        flash[:notice] = "Plan was successfully updated."
        redirect_to dashboard_meta_prompt_url(@meta_prompt), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @meta_prompt.destroy!

      flash[:notice] = "Plan was successfully destroyed."
      redirect_to dashboard_meta_prompts_url, status: :see_other
    end

    private
      def ensure_owner!
        if @meta_prompt.user != current_user
          flash[:alert] = "You have no permission."
          redirect_back fallback_location: dashboard_meta_prompts_url, status: :see_other
        end
      end

      def set_meta_prompt
        @meta_prompt = MetaPrompt.find(params[:id])
      end

      def meta_prompt_params
        params.require(:meta_prompt).permit(
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
