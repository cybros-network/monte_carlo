# frozen_string_literal: true

module Dashboard
  module MetaPrompts
    class ApplicationController < Dashboard::ApplicationController
      before_action :set_meta_prompt
      before_action :ensure_owner!

      protected
        def ensure_owner!
          if @meta_prompt.user != current_user
            flash[:alert] = "You have no permission."
            redirect_back fallback_location: dashboard_meta_prompts_url, status: :see_other
          end
        end

        def set_meta_prompt
          @meta_prompt = MetaPrompt.find(params[:meta_prompt_id])
        end
    end
  end
end
