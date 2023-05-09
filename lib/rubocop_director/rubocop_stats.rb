require "open3"
require "json"
require "yaml"

module RubocopDirector
  class RubocopStats
    def fetch
      Open3.capture3("sed '/todo/d' ./.rubocop.yml > tmpfile; mv tmpfile ./.rubocop.yml")
      stdout, = Open3.capture3("bundle exec rubocop --format json")
      JSON.parse(stdout)
    ensure
      Open3.capture3("git checkout ./.rubocop.yml")
    end
  end
end
