# frozen_string_literal: true

module Constants
  RANDOM_SEED_RANGE = -100000..100000
  STEP_RANGE = 1..30 # 1..150
  WIDTH_RANGE = 64..2048
  HEIGHT_RANGE = 64..2048
  CFG_SCALE_RANGE = (1.0)..(30.0)
  HIRES_FIX_UPSCALE_RANGE = (1.0)..(4.0)
  HIRES_FIX_STEPS_RANGE = 1..30 # 1..150
  HIRES_FIX_DENOISING_RANGE = (0.0)..(1.0)

  SUPPORTED_SD_MODELS = Settings.stable_diffusion.models.map(&:to_h)
  SUPPORTED_SD_MODELS_FOR_SELECT = SUPPORTED_SD_MODELS.filter_map { |e| [e.fetch(:title), e.fetch(:id)] if e.fetch(:enabled, false) }
  SUPPORTED_SD_MODEL_NAMES = SUPPORTED_SD_MODELS.filter_map { |e| e.fetch(:id) if e.fetch(:enabled, false) }

  SUPPORTED_SAMPLERS = Settings.stable_diffusion.samplers
  SUPPORTED_SAMPLER_NAMES = SUPPORTED_SAMPLERS

  SUPPORTED_HIRES_UPSCALER = Settings.stable_diffusion.upscalers
  SUPPORTED_HIRES_UPSCALER_NAMES = SUPPORTED_HIRES_UPSCALER
end
