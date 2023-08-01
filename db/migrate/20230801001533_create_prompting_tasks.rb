class CreatePromptingTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :prompting_tasks do |t|
      t.references :user, null: false, foreign_key: true

      t.references :prompting_plan, null: true, foreign_key: true

      t.text :prompt, null: false
      t.text :negative_prompt
      t.string :sd_model_name, null: false
      t.string :sampler_name, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :seed, null: false
      t.integer :steps, null: false
      t.float :cfg_scale, null: false
      t.boolean :hires_fix, null: false
      t.string :hires_fix_upscaler_name
      t.float :hires_fix_upscale
      t.integer :hires_fix_steps
      t.float :hires_fix_denoising

      t.integer :unique_track_id
      t.text :submitted_prompt
      t.text :generated_image_url

      t.string :status, null: false

      t.timestamps
    end
  end
end
