# frozen_string_literal: true

module Dashboard
  module Glossaries
    class ApplicationController < Dashboard::ApplicationController
      before_action :set_glossary
      before_action :ensure_owner!

      protected
        def ensure_owner!
          if @glossary.user != current_user
            flash[:alert] = "You have no permission."
            redirect_back fallback_location: dashboard_glossaries_url, status: :see_other
          end
        end

        def set_glossary
          @glossary = Glossary.find(params[:glossary_id])
        end
    end
  end
end
