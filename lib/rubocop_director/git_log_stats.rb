require "json"
require "optparse"
require "yaml"

module RubocopDirector
  class GitLogStats
    def initialize(since)
      @since = since
    end

    def fetch
      stdout, = Open3.capture3("git log --since=\"#{@since}\" --pretty=format: --name-only | sort | uniq -c | sort -rg")
      stdout.split("\n")[1..].each_with_object({}) do |line, acc|
        number, path = line.split
        acc[path] = number.to_i
      end
    end
  end
end
