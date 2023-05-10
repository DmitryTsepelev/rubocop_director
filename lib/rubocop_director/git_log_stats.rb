require "json"
require "optparse"
require "yaml"

require "dry/monads"

module RubocopDirector
  class GitLogStats
    include Dry::Monads[:result]

    def initialize(since)
      @since = since
    end

    def fetch
      stdout, stderr = Open3.capture3("git log --since=\"#{@since}\" --pretty=format: --name-only | sort | uniq -c | sort -rg")

      return Failure("Failed to fetch git stats: #{stderr}") if stderr.length > 0

      stats = stdout.split("\n")[1..].each_with_object({}) do |line, acc|
        number, path = line.split
        acc[path] = number.to_i
      end

      Success(stats)
    end
  end
end
