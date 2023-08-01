# frozen_string_literal: true

class PromptElement < ApplicationRecord
  belongs_to :prompting_plan
  belongs_to :glossary, optional: true
end
