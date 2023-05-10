module RubocopDirector
  class FileStatsBuilder
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:build, :find_refactoring_value)

    def initialize(rubocop_json:, update_counts:, config:)
      @rubocop_json = rubocop_json
      @update_counts = update_counts
      @config = config
    end

    def build
      file_stats = files_with_offenses.map do |file|
        stats = {
          path: file["path"],
          updates_count: update_counts[file["path"]] || 0,
          offense_counts: file["offenses"].group_by { |offense| offense["cop_name"] }.transform_values(&:count)
        }

        stats[:value] = yield find_refactoring_value(stats)

        stats
      end

      Success(file_stats.sort_by { _1[:value] }.reverse)
    end

    private

    attr_reader :rubocop_json, :update_counts, :config

    def files_with_offenses = rubocop_json["files"].select { |file| file["offenses"].any? }

    def find_refactoring_value(file)
      update_weight = yield fetch_update_weight

      offence_sum = file[:offense_counts].sum do |cop_name, count|
        cop_weight = yield fetch_cop_weight(cop_name)
        cop_weight * count
      end

      Success((offence_sum * file[:updates_count] * update_weight).to_i)
    end

    def fetch_cop_weight(cop_name)
      weight = config.dig("weights", cop_name) || config["default_cop_weight"]

      if weight
        Success(weight)
      else
        Failure("could not find weight for #{cop_name} and default weight is not configured")
      end
    end

    def fetch_update_weight
      weight = config["update_weight"]

      if weight
        Success(weight)
      else
        Failure("update_weight is not configured")
      end
    end
  end
end
