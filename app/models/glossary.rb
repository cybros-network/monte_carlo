# frozen_string_literal: true

class Glossary < ApplicationRecord
  belongs_to :user, optional: true

  has_many :vocabularies, dependent: :delete_all

  validates :name,
            presence: true,
            allow_blank: false
end
