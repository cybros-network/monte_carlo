# frozen_string_literal: true

module Dashboard
  class PromptingTasksController < Dashboard::ApplicationController
    before_action :set_prompting_task, except: %i[index new create]
    before_action :ensure_owner!, except: %i[index new create]
    before_action :frozen_after_submitted!, except: %i[index new create show]

    def index
      @prompting_tasks = PromptingTask.where(user: current_user).page(params[:page]).per(params[:per_page] || 50)
    end

    def new
      prompting_plan =
        if params[:prompting_plan_id].present?
          PromptingPlan.where(user: current_user).where(id: params[:prompting_plan_id]).first
        end
      @prompting_task = prompting_plan ? prompting_plan.build_prompting_task : PromptingTask.new
    end

    def create
      prompting_plan =
        if params[:prompting_plan_id].present?
          PromptingPlan.where(user: current_user).where(id: params[:prompting_plan_id]).first
        end
      @prompting_task = prompting_plan ? prompting_plan.build_prompting_task : PromptingTask.new
      @prompting_task.user = current_user

      if @prompting_task.save
        flash[:notice] = "Task was successfully created."
        redirect_to dashboard_prompting_task_url(@prompting_task)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      if @prompting_task.update(prompting_task_params)
        flash[:notice] = "Task was successfully updated."
        redirect_to dashboard_prompting_task_url(@prompting_task), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @prompting_task.destroy!

      flash[:notice] = "Task was successfully destroyed."
      redirect_to dashboard_prompting_tasks_url, status: :see_other
    end

    def submit
      @prompting_task.submit!
      redirect_to dashboard_prompting_task_url(@prompting_task), status: :see_other
    end

    private
      def ensure_owner!
        if @prompting_task.user != current_user
          flash[:alert] = "You have no permission."
          redirect_back fallback_location: dashboard_prompting_tasks_url, status: :see_other
        end
      end

      def frozen_after_submitted!
        unless @prompting_task.pending?
          flash[:alert] = "The task has frozen."
          redirect_back fallback_location: dashboard_prompting_task_url(@prompting_task), status: :see_other
        end
      end

      def set_prompting_task
        @prompting_task = PromptingTask.find(params[:id])
      end

      def prompting_task_params
        params.require(:prompting_task).permit(
          :positive_prompt,
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
