# frozen_string_literal: true

class User < ApplicationRecord
  include DeviseFailsafe

  # Include default devise modules. Others available are:
  # :database_authenticatable, :registerable, :confirmable, :recoverable, :invitable, :timeoutable
  devise :database_authenticatable, :registerable,
         :rememberable, :lockable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[siwe]

  scope :active, -> { where(locked_at: nil) }

  has_many :identities, dependent: :delete_all, autosave: true

  validates :name,
            presence: true,
            if: :name_required?

  validates :email,
            uniqueness: true,
            allow_blank: true

  def display_name
    name.present? ? name : email
  end

  protected
    def email_required?
      false
    end

    def confirmation_required?
      email.present? && !confirmed?
    end

    def name_required?
      email.blank?
    end
end
