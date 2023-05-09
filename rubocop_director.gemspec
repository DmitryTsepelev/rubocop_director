# frozen_string_literal: true

require_relative "lib/rubocop_director/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop_director"
  spec.version = RubocopDirector::VERSION
  spec.authors = ["DmitryTsepelev"]
  spec.email = ["dmitry.a.tsepelev@gmail.com"]

  spec.summary = "Plan your refactorings properly."
  spec.description = "Plan your refactorings properly."
  spec.homepage = "https://github.com/DmitryTsepelev/rubocop_director"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DmitryTsepelev/rubocop_director"
  spec.metadata["changelog_uri"] = "https://github.com/DmitryTsepelev/rubocop_director/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[exe/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables << "rubocop-director"
  spec.require_paths = ["lib"]
end
