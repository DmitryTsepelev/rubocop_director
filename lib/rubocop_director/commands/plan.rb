require "open3"
require "json"
require "yaml"
require "date"

require "rubocop_director/rubocop_stats"
require "rubocop_director/git_log_stats"
require "rubocop_director/output_formatter"

module RubocopDirector
  module Commands
    class Plan
      def initialize(since)
        @since = since || Date.new
      end

      def run
        puts "[1/3] Running rubocop to get the list of offences to fix..."
        rubocop_json = RubocopStats.new.fetch

        puts "[2/3] Checking git history since #{@since} to find hot files..."
        update_counts = GitLogStats.new(@since).fetch

        puts "[3/3] Calculating a list of files to refactor..."
        ranged_files =
          file_stats(rubocop_json, update_counts)
            .sort_by { _1[:value] }
            .reverse

        total_value = ranged_files.sum { _1[:value] }

        OutputFormatter.new(ranged_files:, total_value:, since: @since).call
      end

      private

      def cop_weight(cop_name)
        (config.dig("weights", cop_name) || config["default_cop_weight"]).tap do |weight|
          next if weight

          raise ArgumentError, "could not find weight for #{cop_name} and default weight is not configured"
        end
      end

      def config
        @config ||= YAML.load_file(".rubocop-director.yml")
      end

      def update_weight
        config["update_weight"].tap do |weight|
          next if weight

          raise ArgumentError, "update_weight is not configured"
        end
      end

      def file_stats(rubocop_json, update_counts)
        files_with_offenses = rubocop_json["files"].select { |file| file["offenses"].any? }

        files_with_offenses.map do |file|
          stats = {
            path: file["path"],
            updates_count: update_counts[file["path"]] || 0,
            offense_counts: file["offenses"].group_by { |offense| offense["cop_name"] }.transform_values(&:count)
          }

          stats[:value] = find_refactoring_value(stats)

          stats
        end
      end

      def find_refactoring_value(file)
        (file[:offense_counts].sum { |cop_name, count| cop_weight(cop_name) * count } * file[:updates_count] * update_weight).to_i
      end
    end
  end
end
