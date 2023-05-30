require "json"
require "optparse"
require "yaml"

require "dry/monads"

module RubocopDirector
  class OutputFormatter
    include Dry::Monads[:result]

    def initialize(ranged_files:, since:)
      @ranged_files = ranged_files
      @since = since
    end

    def call
      result = @ranged_files.each_with_object([]) do |file, result|
        result << ""

        result << "Path: #{file[:path]}"
        result << "Updated #{file[:updates_count]} times since #{@since}"
        result << "Offenses:"
        file[:offense_counts].each { |cop, count| result << "  🚓 #{cop} - #{count}" }
        result << "Refactoring value: #{file[:value]} (#{(100 * file[:value] / total_value.to_f).round(5)}%)"
      end

      Success(result)
    end

    private

    def total_value = @ranged_files.sum { _1[:value] }
  end
end
