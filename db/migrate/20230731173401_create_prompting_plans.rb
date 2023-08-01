class CreatePromptingPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :prompting_plans do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false
      t.string :sd_model_name, null: false
      t.string :sampler_name, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :fixed_seed
      t.integer :min_steps, null: false
      t.integer :max_steps, null: false
      t.float :min_cfg_scale, null: false
      t.float :max_cfg_scale, null: false
      t.boolean :hires_fix, null: false
      t.string :hires_fix_upscaler_name
      t.float :hires_fix_upscale
      t.integer :hires_fix_min_steps
      t.integer :hires_fix_max_steps
      t.float :hires_fix_min_denoising
      t.float :hires_fix_max_denoising

      t.integer :positive_prompt_elements_count, null: false, default: 0
      t.integer :negative_prompt_elements_count, null: false, default: 0

      t.timestamps
    end
  end
end
