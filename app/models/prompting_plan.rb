# frozen_string_literal: true

class PromptingPlan < ApplicationRecord
  belongs_to :user

  has_many :prompt_elements, dependent: :delete_all

  has_many :prompting_tasks, dependent: :nullify

  validates :name,
            presence: true,
            allow_blank: false

  validates :sd_model_name,
            presence: true,
            inclusion: {
              in: Constants::SUPPORTED_SD_MODEL_NAMES,
              message: "%{value} isn't supported."
            },
            allow_blank: false

  validates :sampler_name,
            presence: true,
            inclusion: {
              in: Constants::SUPPORTED_SAMPLER_NAMES,
              message: "%{value} isn't supported."
            },
            allow_blank: false

  validates :width,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::WIDTH_RANGE.begin,
              less_than_or_equal_to: Constants::WIDTH_RANGE.end
            },
            allow_blank: false

  validates :height,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::HEIGHT_RANGE.begin,
              less_than_or_equal_to: Constants::HEIGHT_RANGE.end
            },
            allow_blank: false

  validates :fixed_seed,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::RANDOM_SEED_RANGE.begin,
              less_than_or_equal_to: Constants::RANDOM_SEED_RANGE.end
            },
            allow_blank: false,
            allow_nil: true

  validates :min_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::STEP_RANGE.begin,
              less_than_or_equal_to: Constants::STEP_RANGE.end,
            },
            allow_blank: false

  validates :max_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::STEP_RANGE.begin,
              less_than_or_equal_to: Constants::STEP_RANGE.end
            },
            allow_blank: false
  validate do |record|
    if record.max_steps < record.min_steps
      record.errors.add :max_steps, :greater_than_or_equal_to, record.min_steps
    end
  end

  validates :min_cfg_scale,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: Constants::CFG_SCALE_RANGE.begin,
              less_than_or_equal_to: Constants::CFG_SCALE_RANGE.end
            },
            allow_blank: false

  validates :max_cfg_scale,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: Constants::CFG_SCALE_RANGE.begin,
              less_than_or_equal_to: Constants::CFG_SCALE_RANGE.end
            },
            allow_blank: false
  validate do |record|
    if record.max_cfg_scale < record.min_cfg_scale
      record.errors.add :max_cfg_scale, :greater_than_or_equal_to, record.min_cfg_scale
    end
  end

  validates :hires_fix_upscaler_name,
            presence: true,
            inclusion: {
              in: Constants::SUPPORTED_HIRES_UPSCALER_NAMES,
              message: "%{value} isn't supported."
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_upscale,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: Constants::HIRES_FIX_UPSCALE_RANGE.begin,
              less_than_or_equal_to: Constants::HIRES_FIX_UPSCALE_RANGE.end
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_min_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::HIRES_FIX_STEPS_RANGE.begin,
              less_than_or_equal_to: Constants::HIRES_FIX_STEPS_RANGE.end
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_max_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: Constants::HIRES_FIX_STEPS_RANGE.begin,
              less_than_or_equal_to: Constants::HIRES_FIX_STEPS_RANGE.end
            },
            allow_blank: false,
            if: :hires_fix?
  validate do |record|
    next unless record.hires_fix?

    if record.hires_fix_max_steps < record.hires_fix_min_steps
      record.errors.add :hires_fix_max_steps, :greater_than_or_equal_to, record.hires_fix_min_steps
    end
  end

  validates :hires_fix_min_denoising,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: Constants::HIRES_FIX_DENOISING_RANGE.begin,
              less_than_or_equal_to: Constants::HIRES_FIX_DENOISING_RANGE.end
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_max_denoising,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: Constants::HIRES_FIX_DENOISING_RANGE.begin,
              less_than_or_equal_to: Constants::HIRES_FIX_DENOISING_RANGE.end
            },
            allow_blank: false,
            if: :hires_fix?
  validate do |record|
    next unless record.hires_fix?

    if record.hires_fix_max_denoising < record.hires_fix_min_denoising
      record.errors.add :hires_fix_max_denoising, :greater_than_or_equal_to, record.hires_fix_min_denoising
    end
  end

  after_initialize do |record|
    next unless record.new_record?

    record.name ||= "Untitled plan"
    record.sd_model_name ||= Constants::SUPPORTED_SD_MODEL_NAMES.first
    record.sampler_name ||= Constants::SUPPORTED_SAMPLER_NAMES.first
    record.width ||= 512
    record.height ||= 512
    record.min_steps ||= 5
    record.max_steps ||= 25
    record.min_cfg_scale ||= 7
    record.max_cfg_scale ||= 7
    record.hires_fix ||= false
    record.hires_fix_upscaler_name ||= Constants::SUPPORTED_HIRES_UPSCALER_NAMES.first
    record.hires_fix_upscale ||= 2
    record.hires_fix_min_steps ||= 1
    record.hires_fix_max_steps ||= 1
    record.hires_fix_min_denoising ||= 0.7
    record.hires_fix_max_denoising ||= 0.7
  end

  def build_prompting_task
    round_to = -> (b, v) {
      (b / v).round * v
    }

    prompts = []
    negative_prompts = []
    prompt_elements.includes(glossary: :vocabularies).sort_by(&:order).reverse_each do |elem|
      case elem
      when VocabularyPromptElement
        if elem.negative?
          negative_prompts << elem.text
        else
          prompts << elem.text
        end
      when GlossaryPromptElement
        elem.glossary.vocabularies.sample(elem.frequency).each do |vocabulary|
          if elem.negative?
            negative_prompts << vocabulary.text
          else
            prompts << vocabulary.text
          end
        end
      else
        next
      end
    end

    prompting_tasks.build(
      prompt: prompts.join(","),
      negative_prompt: negative_prompts.join(","),
      sd_model_name: sd_model_name,
      sampler_name: sampler_name,
      width: width,
      height: height,
      seed: fixed_seed.present? ? fixed_seed : rand(Constants::RANDOM_SEED_RANGE),
      steps: rand(min_steps..max_steps),
      cfg_scale: round_to.call(rand(min_cfg_scale..max_cfg_scale), 0.5),
      hires_fix: hires_fix,
      hires_fix_upscaler_name: hires_fix_upscaler_name,
      hires_fix_upscale: round_to.call(hires_fix_upscale, 0.05),
      hires_fix_steps: rand(hires_fix_min_steps..hires_fix_max_steps),
      hires_fix_denoising: rand(hires_fix_min_denoising..hires_fix_max_denoising).round(2)
    )
  end
end
