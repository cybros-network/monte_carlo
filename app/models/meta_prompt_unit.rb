# frozen_string_literal: true

class MetaPromptUnit < ApplicationRecord
  belongs_to :meta_prompt
  belongs_to :glossary, optional: true

  validates :type,
            presence: true,
            allow_blank: false
end
