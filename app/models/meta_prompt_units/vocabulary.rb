# frozen_string_literal: true

module MetaPromptUnits
  class Vocabulary < MetaPromptUnit
    validates :text,
              presence: true,
              allow_blank: false
  end
end
