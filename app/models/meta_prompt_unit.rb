# frozen_string_literal: true

class MetaPromptUnit < ApplicationRecord
  belongs_to :meta_prompt
  belongs_to :glossary, optional: true

  validates :type,
            presence: true,
            allow_blank: false

  after_save do |record|
    units = record.meta_prompt.units.pluck(:negative)
    positive_units_count = units.filter(&:itself).size
    negative_units_count = units.size - positive_units_count

    record.meta_prompt.update_columns(
      positive_units_count: positive_units_count,
      negative_units_count: negative_units_count
    )
  end
end
