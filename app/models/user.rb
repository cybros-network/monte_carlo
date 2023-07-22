# frozen_string_literal: true

class User < ApplicationRecord
  include DeviseFailsafe

  # Include default devise modules. Others available are:
  # :confirmable, :recoverable, :timeoutable
  devise :database_authenticatable,
         :registerable, :lockable, :invitable,
         :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[siwe]

  scope :active, -> { where(locked_at: nil) }

  has_many :identities, dependent: :delete_all, autosave: true

  validates :name,
            presence: true,
            if: :name_required?

  def display_name
    name.present? ? name : email
  end

  protected
    def email_required?
      false
    end

    def name_required?
      email.blank?
    end
end
