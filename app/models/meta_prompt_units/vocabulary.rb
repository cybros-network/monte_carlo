# frozen_string_literal: true

module MetaPromptUnits
  class Vocabulary < MetaPromptUnit
    validates :text,
              presence: true,
              allow_blank: false

    # TODO: forbidden words, like unsupported LoRa
  end
end
