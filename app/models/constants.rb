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

  SUPPORTED_SD_MODELS = [
    {
      name: "nekothecat_nekov3",
      desc: "",
      enabled: true
    },
    {
      name: "CounterfeitV30_v30",
      desc: "",
      enabled: true
    },
    {
      name: "abyssorangemix3AOM3_aom3a1b",
      desc: "",
      enabled: true
    }
  ]
  SUPPORTED_SD_MODEL_NAMES = SUPPORTED_SD_MODELS.filter_map { |e| e.fetch(:name) if e.fetch(:enabled, false) }

  SUPPORTED_SAMPLERS = [
    {
      name: "Euler a",
      desc: "",
      enabled: true
    },
    {
      name: "Euler",
      desc: "",
      enabled: true
    },
    {
      name: "LMS",
      desc: "",
      enabled: true
    },
    {
      name: "Heun",
      desc: "",
      enabled: true
    },
    {
      name: "DPM2",
      desc: "",
      enabled: true
    },
    {
      name: "DPM2 a",
      desc: "",
      enabled: true
    },
    {
      name: "DPM++ 2S a",
      desc: "",
      enabled: true
    },
    {
      name: "DPM++ 2M",
      desc: "",
      enabled: true
    },
    {
      name: "DPM++ SDE",
      desc: "",
      enabled: true
    },
    {
      name: "DPM fast",
      desc: "",
      enabled: true
    },
    {
      name: "DPM adaptive",
      desc: "",
      enabled: true
    },
    {
      name: "LMS Karras",
      desc: "",
      enabled: true
    },
    {
      name: "DPM2 Karras",
      desc: "",
      enabled: true
    },
    {
      name: "DPM2 a Karras",
      desc: "",
      enabled: true
    },
    {
      name: "DPM++ 2S a Karras",
      desc: "",
      enabled: true
    },
    {
      name: "DPM++ 2M Karras",
      desc: "",
      enabled: true
    },
    {
      name: "DPM++ SDE Karras",
      desc: "",
      enabled: true
    },
    {
      name: "DDIM",
      desc: "",
      enabled: true
    },
    {
      name: "PLMS",
      desc: "",
      enabled: true
    },
    {
      name: "UniPC",
      desc: "",
      enabled: true
    }
  ]
  SUPPORTED_SAMPLER_NAMES = SUPPORTED_SAMPLERS.filter_map { |e| e.fetch(:name) if e.fetch(:enabled, false) }

  SUPPORTED_HIRES_UPSCALER = [
    {
      name: "None",
      desc: "",
      enabled: true
    },
    {
      name: "Lanczos",
      desc: "",
      enabled: true
    },
    {
      name: "Nearest",
      desc: "",
      enabled: true
    },
    {
      name: "ESRGAN_4x",
      desc: "",
      enabled: true
    },
    {
      name: "LDSR",
      desc: "",
      enabled: true
    },
    {
      name: "R-ESRGAN 4x+",
      desc: "",
      enabled: true
    },
    {
      name: "R-ESRGAN 4x+ Anime6B",
      desc: "",
      enabled: true
    },
    {
      name: "ScuNET GAN",
      desc: "",
      enabled: true
    },
    {
      name: "ScuNET PSNR",
      desc: "",
      enabled: true
    },
    {
      name: "SwinIR 4x",
      desc: "",
      enabled: true
    }
  ]
  SUPPORTED_HIRES_UPSCALER_NAMES = SUPPORTED_HIRES_UPSCALER.filter_map { |e| e.fetch(:name) if e.fetch(:enabled, false) }
end
