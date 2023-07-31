# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_root_url
    end
  end

  def terms
  end

  def privacy
  end
end
