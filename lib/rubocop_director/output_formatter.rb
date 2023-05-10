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
        result << "-" * 20
        result << file[:path]
        result << "updated #{file[:updates_count]} times since #{@since}"
        result << "offences: #{file[:offense_counts].map { |cop, count| "#{cop} - #{count}" }.join(", ")}"
        result << "refactoring value: #{file[:value]} (#{(100 * file[:value] / total_value.to_f).round(5)}%)"
      end

      Success(result)
    end

    private

    def total_value = @ranged_files.sum { _1[:value] }
  end
end
