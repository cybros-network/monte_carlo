# frozen_string_literal: true

module MetaPromptUnits
  class Glossary < MetaPromptUnit
    validates :glossary,
              presence: true,
              allow_blank: false

    validates :frequency,
              presence: true,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 1
              },
              allow_blank: false

    after_initialize do |record|
      next unless record.new_record?

      record.frequency ||= 1
    end
  end
end
