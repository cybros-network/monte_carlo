# frozen_string_literal: true

class PromptingPlan < ApplicationRecord
  belongs_to :user

  has_many :prompt_elements, dependent: :delete_all

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
              greater_than_or_equal_to: 64,
              less_than_or_equal_to: 2048
            },
            allow_blank: false

  validates :height,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 64,
              less_than_or_equal_to: 2048
            },
            allow_blank: false

  validates :fixed_seed,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: -100000,
              less_than_or_equal_to: 100000
            },
            allow_blank: true

  validates :min_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 25, # 150
            },
            allow_blank: false

  validates :max_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 25, # 150
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
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 30,
            },
            allow_blank: false

  validates :max_cfg_scale,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 30
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
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 4
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_min_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 25, # 150
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_max_steps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 25, # 150
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
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1,
            },
            allow_blank: false,
            if: :hires_fix?

  validates :hires_fix_max_denoising,
            presence: true,
            numericality: {
              only_integer: false,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1
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
end
