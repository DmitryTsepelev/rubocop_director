require "json"
require "optparse"
require "yaml"

module RubocopDirector
  class OutputFormatter
    def initialize(ranged_files:, total_value:, since:)
      @ranged_files = ranged_files
      @total_value = total_value
      @since = since
    end

    def call
      @ranged_files.each do |file|
        puts "-" * 20
        puts file[:path]
        puts "updated #{file[:updates_count]} times since #{@since}"
        puts "offences: #{file[:offense_counts].map { |cop, count| "#{cop} - #{count}" }.join(", ")}"
        puts "refactoring value: #{file[:value]} (#{(100 * file[:value] / @total_value.to_f).round(5)}%)"
      end
    end
  end
end
