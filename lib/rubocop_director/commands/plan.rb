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

      def initialize(director_config:, rubocop_config:, since: "1995-01-01")
        @since = since.to_s
        @director_config = director_config
        @rubocop_config = rubocop_config
      end

      def run
        config = yield load_config
        rubocop_json = yield load_rubocop_json
        update_counts = yield load_git_stats
        ranged_files = yield range_files(rubocop_json: rubocop_json, update_counts: update_counts, config: config)

        OutputFormatter.new(ranged_files: ranged_files, since: @since).call
      end

      private

      def load_config
        Success(YAML.load_file(@director_config))
      rescue Errno::ENOENT
        Failure("#{@director_config} not found, generate it using `rubocop-director --generate-config`")
      end

      def load_rubocop_json
        puts "💡 Running rubocop to get the list of offences to fix..."
        RubocopStats.new(@rubocop_config).fetch
      end

      def load_git_stats
        puts "💡🎥 Checking git history since #{@since} to find hot files..."
        GitLogStats.new(@since).fetch
      end

      def range_files(rubocop_json:, update_counts:, config:)
        puts "💡🎥🎬 Calculating a list of files to refactor..."
        FileStatsBuilder.new(rubocop_json: rubocop_json, update_counts: update_counts, config: config).build
      end
    end
  end
end
