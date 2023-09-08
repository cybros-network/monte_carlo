# frozen_string_literal: true

class KeyValue < ApplicationRecord
  serialize :json_value, coder: JSON

  class << self
    def job_pool_workers_stats
      find_or_create_by! key: "job_pool_workers_stats" do |record|
        record.json_value = {
          total_workers_count: 0,
          online_workers_count: 0,
          updated_at: nil
        }
      end
    end
  end
end
