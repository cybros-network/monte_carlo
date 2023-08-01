# frozen_string_literal: true

class VocabularyPromptElement < PromptElement
  validates :text,
            presence: true,
            allow_blank: false
end
