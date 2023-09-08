# frozen_string_literal: true

module Dashboard
  class PromptTasksController < Dashboard::ApplicationController
    before_action :set_prompt_task, except: %i[index new create batch_create]
    before_action :ensure_owner!, except: %i[index new create batch_create]
    before_action :frozen_after_submitted!, except: %i[index new create batch_create show]

    def index
      @prompt_tasks = PromptTask.where(user: current_user).order(id: :desc).page(params[:page]).per(params[:per_page] || 50)
    end

    def batch_create
      meta_prompt =
        if params[:meta_prompt_id].present?
          MetaPrompt.where(user: current_user).where(id: params[:meta_prompt_id]).first
        end
      unless meta_prompt
        flash[:notice] = "Meta prompt not found."
        redirect_back_or_to dashboard_prompt_tasks_url
        return
      end

      created_prompt_tasks = []
      batch_size = params[:batch_size].to_i || 4
      batch_size.times do
        prompt_task = meta_prompt.build_prompt_task
        prompt_task.user = current_user

        if prompt_task.save
          created_prompt_tasks << prompt_task
        end
      end

      if params[:auto_submit]
        created_prompt_tasks.each(&:submit!)
      end

      flash[:notice] = "Batch created #{created_prompt_tasks.size} tasks"
      redirect_to dashboard_prompt_tasks_url
    end

    def new
      meta_prompt =
        if params[:meta_prompt_id].present?
          MetaPrompt.where(user: current_user).where(id: params[:meta_prompt_id]).first
        end
      @prompt_task = meta_prompt ? meta_prompt.build_prompt_task : PromptTask.new
    end

    def create
      meta_prompt =
        if params[:meta_prompt_id].present?
          MetaPrompt.where(user: current_user).where(id: params[:meta_prompt_id]).first
        end
      @prompt_task = meta_prompt ? meta_prompt.build_prompt_task : PromptTask.new
      @prompt_task.user = current_user

      if @prompt_task.save
        flash[:notice] = "Task was successfully created."
        redirect_to dashboard_prompt_task_url(@prompt_task)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      if @prompt_task.update(prompt_task_params)
        flash[:notice] = "Task was successfully updated."
        redirect_to dashboard_prompt_task_url(@prompt_task), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @prompt_task.destroy!

      flash[:notice] = "Task was successfully destroyed."
      redirect_to dashboard_prompt_tasks_url, status: :see_other
    end

    def submit
      @prompt_task.submit!
      redirect_to dashboard_prompt_task_url(@prompt_task), status: :see_other
    end

    private
      def ensure_owner!
        if @prompt_task.user != current_user
          flash[:alert] = "You have no permission."
          redirect_back fallback_location: dashboard_prompt_tasks_url, status: :see_other
        end
      end

      def frozen_after_submitted!
        unless @prompt_task.pending?
          flash[:alert] = "The task has frozen."
          redirect_back fallback_location: dashboard_prompt_task_url(@prompt_task), status: :see_other
        end
      end

      def set_prompt_task
        @prompt_task = PromptTask.find(params[:id])
      end

      def prompt_task_params
        params.require(:prompt_task).permit(
          :prompt,
          :negative_prompt,
          :sd_model_name,
          :sampler_name,
          :width,
          :height,
          :seed,
          :steps,
          :cfg_scale,
          :hires_fix,
          :hires_fix_upscaler_name,
          :hires_fix_upscale,
          :hires_fix_steps,
          :hires_fix_denoising
        )
      end
  end
end
