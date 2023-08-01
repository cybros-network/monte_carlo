# frozen_string_literal: true

class PromptElement < ApplicationRecord
  belongs_to :prompting_plan
  belongs_to :glossary, optional: true

  after_save do |record|
    elements = record.prompting_plan.prompt_elements.pluck(:negative)
    positive_elements_count = elements.filter(&:itself).size
    negative_elements_count = elements.size - positive_elements_count

    record.prompting_plan.update_columns(
      positive_prompt_elements_count: positive_elements_count,
      negative_prompt_elements_count: negative_elements_count
    )
  end
end
