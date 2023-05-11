require "open3"
require "json"
require "yaml"
require "date"

require "rubocop_director/rubocop_stats"
require "rubocop_director/git_log_stats"
require "rubocop_director/file_stats_builder"
require "rubocop_director/output_formatter"

module RubocopDirector
  module Commands
    class Plan
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:run)

      def initialize(since)
        @since = since || Date.new
      end

      def run
        config = yield load_config
        update_counts = yield load_git_stats
        rubocop_json = yield load_rubocop_json
        ranged_files = yield range_files(rubocop_json: rubocop_json, update_counts: update_counts, config: config)

        OutputFormatter.new(ranged_files: ranged_files, since: @since).call
      end

      private

      def load_config
        Success(YAML.load_file(CONFIG_NAME))
      rescue Errno::ENOENT
        Failure("#{CONFIG_NAME} not found, generate it using --generate-config")
      end

      def load_git_stats
        puts "[1/3] Checking git history since #{@since} to find hot files..."
        GitLogStats.new(@since).fetch
      end

      def load_rubocop_json
        puts "[2/3] Running rubocop to get the list of offences to fix..."
        RubocopStats.new.fetch
      end

      def range_files(rubocop_json:, update_counts:, config:)
        puts "[3/3] Calculating a list of files to refactor..."
        RubocopDirector::FileStatsBuilder.new(rubocop_json: rubocop_json, update_counts: rubocop_json, config: config).build
      end
    end
  end
end
