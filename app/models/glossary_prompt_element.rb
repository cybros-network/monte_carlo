# frozen_string_literal: true

class GlossaryPromptElement < PromptElement
  validates :glossary,
            presence: true,
            allow_blank: false

  validates :frequency,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 8
            },
            allow_blank: false

  after_initialize do |record|
    next unless record.new_record?

    record.frequency ||= 1
  end
end
