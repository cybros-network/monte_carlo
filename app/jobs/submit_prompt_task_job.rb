# frozen_string_literal: true

class SubmitPromptTaskJob < ApplicationJob
  queue_as :default

  def perform(prompt_task_id)
    task = PromptTask.find(prompt_task_id) rescue nil
    return unless task
    # TODO:
    # return unless task.submitting? || task.errored?

    client = Aws::S3::Client.new(
      region: Settings.task_forwarder.s3_region, # fake
      endpoint: Settings.task_forwarder.s3_endpoint,
      credentials: Aws::Credentials.new(
        Settings.task_forwarder.s3_access_key_id,
        Settings.task_forwarder.s3_secret_access_key
      ),
      force_path_style: true
    )

    uuid = SecureRandom.uuid
    signer = Aws::S3::Presigner.new(client: client)

    image_upload_url = signer.presigned_url(
      :put_object,
      bucket: Settings.task_forwarder.s3_bucket,
      key: "#{uuid}.png",
      expires_in: 3.days.to_i,
      secure: Settings.task_forwarder.s3_use_ssl
    )
    parsed = URI.parse(image_upload_url)
    parsed.fragment = parsed.query = nil
    image_download_url = parsed.to_s

    proof_upload_url = signer.presigned_url(
      :put_object,
      bucket: Settings.task_forwarder.s3_bucket,
      key: "#{uuid}.json",
      expires_in: 3.days.to_i,
      secure: Settings.task_forwarder.s3_use_ssl
    )

    parsed = URI.parse(proof_upload_url)
    parsed.fragment = parsed.query = nil
    proof_download_url = parsed.to_s

    data = {
      image_upload_url: image_upload_url,
      proof_upload_url: proof_upload_url,
      prompt: task.positive_prompt,
      negative_prompt: task.negative_prompt,
      sd_model_name: task.sd_model_name,
      sampler_name: task.sampler_name,
      width: task.width,
      height: task.height,
      seed: task.seed,
      steps: task.steps,
      cfg_scale: task.cfg_scale,
      hr_fix: task.hires_fix,
      hr_fix_upscaler_name: task.hires_fix_upscaler_name,
      hr_fix_upscale: task.hires_fix_upscale,
      hr_fix_steps: task.hires_fix_steps,
      hr_fix_denoising: task.hires_fix_denoising
    }

    response =
      begin
        Faraday.post "#{Settings.task_forwarder.endpoint}/submit" do |req|
          req.headers[:content_type] = "application/json"
          req.body = {
            unique_track_id: task.unique_track_id,
            data: data,
          }.to_json
        end
      rescue Faraday::Error => e
        # You can handle errors here (4xx/5xx responses, timeouts, etc.)
        Rails.logger.error e.response[:status]
        Rails.logger.error e.response[:body]

        nil
      end

    if response&.status != 200
      task.status = :errored
      task.errored_at = Time.zone.now
      task.save validate: false

      return
    end

    Rails.logger.info response[:body]

    task.generated_image_url = image_download_url
    task.generated_proof_url = proof_download_url
    task.status = :submitted
    task.submitted_at = Time.zone.now
    task.errored_at = nil
    task.save validate: false
  end
end
