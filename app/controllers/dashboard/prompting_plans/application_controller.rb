# frozen_string_literal: true

module Dashboard
  module PromptingPlans
    class ApplicationController < Dashboard::ApplicationController
      before_action :set_prompting_plan
      before_action :ensure_owner!

      protected
        def ensure_owner!
          if @prompting_plan.user != current_user
            flash[:alert] = "You have no permission."
            redirect_back fallback_location: dashboard_prompting_plans_url, status: :see_other
          end
        end

        def set_prompting_plan
          @prompting_plan = PromptingPlan.find(params[:prompting_plan_id])
        end
    end
  end
end
