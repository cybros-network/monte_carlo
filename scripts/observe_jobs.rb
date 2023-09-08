#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
CURRENT_PATH = Pathname.new File.expand_path(__dir__)

require_relative "../config/environment"
require "dotenv"
Dotenv.load(CURRENT_PATH.join(".env"), CURRENT_PATH.join(".env.defaults"))

require "graphql/client"
require "graphql/client/http"

HTTP = GraphQL::Client::HTTP.new(ENV.fetch("SQUID_GQL_ENDPOINT")) do
  # def headers(context)
  #   # Optionally set any HTTP headers
  #   { "User-Agent": "My Client" }
  # end
end

# Fetch latest schema on init, this will make a network request
Schema = GraphQL::Client.load_schema(HTTP)

# However, it's smart to dump this to a JSON file and load from disk
#
# Run it from a script or rake task
#   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
#
# Schema = GraphQL::Client.load_schema("path/to/schema.json")

Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

FindJobQuery = Client.parse <<-GRAPHQL
  query($pid: Int, $uid: Int) {
    jobs(where: {poolId_eq: $pid, uniqueTrackId_eq: $uid}, orderBy: jobId_DESC) {
      jobId
      uniqueTrackId
      poolId
      policyId
      implSpecVersion
      status
      input
      output
      result
      events(orderBy: sequence_DESC) {
        blockNumber
        blockTime
        kind
        payload
      }
    }
  }
GRAPHQL

def run
  PromptTask.where(status: %i[submitted processing]).find_each do |task|
    result = Client.query(
      FindJobQuery,
      variables: {
        pid: ENV.fetch("JOB_POOL_ID").to_i, uid: task.unique_track_id
      },
      context: {}
    )

    record = result.data.jobs.first
    unless record
      puts "Record not found for PromptTask(id: #{task.id} track-id: #{task.unique_track_id})."
      next
    end

    if record.job_id < ENV.fetch("JOB_ID_STARTED_AT").to_i
      next
    end

    record.events.reverse_each do |event|
      # pp event
      case event.kind
      when "Processing"
        task.status = :processing
        task.processing_at = Time.parse(event.block_time)
      when "Success"
        task.status = :processed
        task.processing_at = Time.parse(event.block_time)

        parsed_output = JSON.parse(record.output)
        parsed_data = parsed_output.fetch("data")
        task.result = :success
        task.raw_output = record.output
        task.generated_image_url = parsed_data.fetch("imageUrl")
        task.generated_proof_url = parsed_data.fetch("proofUrl")
      when "Fail"
        task.status = :processed
        task.processing_at = Time.parse(event.block_time)

        task.result = :fail
        task.raw_output = record.output
      when "Error"
        task.status = :processed
        task.processing_at = Time.parse(event.block_time)

        task.result = :error
        task.raw_output = record.output
      when "Panic"
        task.status = :processed
        task.processing_at = Time.parse(event.block_time)

        task.result = :panic
        task.raw_output = record.output
      when "Discarded"
        task.status = :processed
        task.processing_at = Time.parse(event.block_time)

        task.status = :discarded
        task.processing_at = Time.parse(event.block_time)
      else
        # OptOut Created, Assigned, Destroyed
        # raise "Unknown kind #{event.kind} - Job##{record.job_id}"
        next
      end
    end

    task.save validate: false

    puts "Processed PromptTask(id: #{task.id} track-id: #{task.unique_track_id})"
  end
end

LONG_RUN = ENV["LONG_RUN"] == "1"

if LONG_RUN
  loop do
    puts "#{Time.zone.now} Fetching tasks..."
    run
    sleep 6
  end
else
  run
end
