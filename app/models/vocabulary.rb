# frozen_string_literal: true

class Vocabulary < ApplicationRecord
  belongs_to :glossary

  validates :text,
            presence: true,
            uniqueness: {
              scope: :glossary_id
            },
            allow_blank: false
  validates :glossary_id,
            presence: true

  # TODO: forbidden words, like unsupported LoRa
end
