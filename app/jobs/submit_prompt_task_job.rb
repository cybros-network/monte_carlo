# frozen_string_literal: true

class SubmitPromptTaskJob < ApplicationJob
  queue_as :default

  def perform(prompt_task_id)
    task = PromptTask.find(prompt_task_id) rescue nil
    return unless task
    # TODO:
    # return unless task.submitting? || task.errored?

    cmd = [
      Settings.scripts.deno_command,
      "run",
      "--allow-all",
      Settings.scripts.submit_task_script_name,
      "--track-id", task.unique_track_id,
      "--prompt", "'#{task.frozen_prompt}'"
    ].join(" ")
    Rails.logger.debug cmd

    Dir.chdir Rails.root.join("scripts") do
      Open3.popen2e(cmd) do |_stdin, stdout_err, wait_thr|
        while (line = stdout_err.gets)
          Rails.logger.debug line
        end

        exit_status = wait_thr.value
        if exit_status.success?
          task.status = :submitted
          task.submitted_at = Time.zone.now
          task.errored_at = nil
          task.save validate: false
        else
          task.status = :errored
          task.errored_at = Time.zone.now
          task.save validate: false
        end
      end
    end
  end
end
