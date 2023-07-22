# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :extern_uid, allow_blank: true, uniqueness: { scope: :provider, case_sensitive: false }
  validates :user, uniqueness: { scope: :provider }

  scope :with_provider, ->(provider) { where(provider: provider) }
end
