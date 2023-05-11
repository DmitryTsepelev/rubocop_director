require "open3"
require "json"
require "yaml"

require "dry/monads"

module RubocopDirector
  class RubocopStats
    include Dry::Monads[:result]

    def fetch
      _, stderr = Open3.capture3("sed '/todo/d' ./.rubocop.yml > tmpfile; mv tmpfile ./.rubocop.yml")
      if stderr.length > 0
        return Failure("Failed to remove TODO from rubocop config: #{stderr}")
      end

      stdout, stderr = Open3.capture3("bundle exec rubocop --format json")

      if stderr.length > 0
        Failure("Failed to fetch rubocop stats: #{stderr}")
      else
        Success(JSON.parse(stdout)["files"])
      end
    ensure
      Open3.capture3("git checkout ./.rubocop.yml")
    end
  end
end
