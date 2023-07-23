# frozen_string_literal: true

module Accounts
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }

    protected
      def set_page_layout_data
        prepare_meta_tags title: t("accounts.#{controller_name}.show.title")
        @_sidebar_name = "accounts"
      end

      def ensure_authenticatable!
        unless Devise.mappings[:user].database_authenticatable?
          redirect_back fallback_location: root_url
        end
      end
  end
end
