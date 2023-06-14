require "dry/monads"

RSpec.describe RubocopDirector::Commands::Plan do
  include Dry::Monads[:result]

  subject { command.run }

  let(:director_config_path) { Pathname.new(".rubocop_director.yml") }
  let(:rubocop_config_path) { Pathname.new(".rubocop.yml") }
  let(:since) { "1995-01-01" }
  let(:args) { {director_config: director_config_path, rubocop_config: rubocop_config_path, since: since} }
  let(:command) { described_class.new(**args) }

  let(:git_log_stats_fetch_result) do
    Success("app/models/user.rb" => 136, "app/controllers/user_controller.rb" => 99)
  end
  let(:git_log_stats_mock) { OpenStruct.new(fetch: git_log_stats_fetch_result) }

  let(:rubocop_stats_fetch_result) do
    Success(
      [
        {
          "offenses" =>
            [
              {"cop_name" => "Rails/SomeCop"},
              {"cop_name" => "Rails/AnotherCop"}
            ],
          "path" => "app/models/user.rb"
        },
        {
          "offenses" =>
            [
              {"cop_name" => "Rails/SomeCop"},
              {"cop_name" => "Rails/SomeCop"}
            ],
          "path" => "app/controllers/user_controller.rb"
        }
      ]
    )
  end
  let(:rubocop_stats_mock) { OpenStruct.new(fetch: rubocop_stats_fetch_result) }

  let(:config_content) do
    {
      "default_cop_weight" => 0.2,
      "update_weight" => 0.3,
      "weights" => {
        "Rails/SomeCop" => 1,
        "Rails/AnotherCop" => 0.5
      }
    }
  end

  before do
    allow(command).to receive(:puts)
    allow(YAML).to receive(:load_file).with(director_config_path).and_return(config_content)
    allow(RubocopDirector::GitLogStats).to receive(:new).and_return(git_log_stats_mock)
    allow(RubocopDirector::RubocopStats).to receive(:new).and_return(rubocop_stats_mock)
  end

  it "returns success" do
    expect(subject).to be_success

    expect(subject.value!).to eq(
      [
        "",
        "Path: app/controllers/user_controller.rb",
        "Updated 99 times since 1995-01-01",
        "Offenses:",
        "  🚓 Rails/SomeCop - 2",
        "Refactoring value: 1.5431217598108933 (54.79575%)",
        "",
        "Path: app/models/user.rb",
        "Updated 136 times since 1995-01-01",
        "Offenses:",
        "  🚓 Rails/SomeCop - 1",
        "  🚓 Rails/AnotherCop - 1",
        "Refactoring value: 1.2730122208719792 (45.20425%)"
      ]
    )
  end

  it "puts to stdout" do
    subject
    expect(command).to have_received(:puts).ordered.with("💡 Running rubocop to get the list of offences to fix...")
    expect(command).to have_received(:puts).ordered.with("💡🎥 Checking git history since 1995-01-01 to find hot files...")
    expect(command).to have_received(:puts).ordered.with("💡🎥🎬 Calculating a list of files to refactor...")
  end

  context "when since is passed" do
    let(:since) { "2023-01-01" }

    it "returns success with passed date" do
      expect(subject).to be_success

      expect(subject.value!).to eq(
        [
          "",
          "Path: app/controllers/user_controller.rb",
          "Updated 99 times since 2023-01-01",
          "Offenses:",
          "  🚓 Rails/SomeCop - 2",
          "Refactoring value: 1.5431217598108933 (54.79575%)",
          "",
          "Path: app/models/user.rb",
          "Updated 136 times since 2023-01-01",
          "Offenses:",
          "  🚓 Rails/SomeCop - 1",
          "  🚓 Rails/AnotherCop - 1",
          "Refactoring value: 1.2730122208719792 (45.20425%)"
        ]
      )
    end

    it "puts to stdout with passed date" do
      subject
      expect(command).to have_received(:puts).ordered.with("💡 Running rubocop to get the list of offences to fix...")
      expect(command).to have_received(:puts).ordered.with("💡🎥 Checking git history since #{since} to find hot files...")
      expect(command).to have_received(:puts).ordered.with("💡🎥🎬 Calculating a list of files to refactor...")
    end
  end

  context "when director_config file does not exists" do
    before do
      allow(YAML).to receive(:load_file).with(director_config_path).and_raise(Errno::ENOENT)
    end

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq(".rubocop_director.yml not found, generate it using `rubocop-director --generate-config`")
    end
  end

  context "when GitLogStats returns failure" do
    let(:git_log_stats_fetch_result) { Failure("git log stats error") }

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("git log stats error")
    end

    it "puts to stdout" do
      subject
      expect(command).to have_received(:puts).ordered.with("💡 Running rubocop to get the list of offences to fix...")
      expect(command).to have_received(:puts).ordered.with("💡🎥 Checking git history since 1995-01-01 to find hot files...")
      expect(command).not_to have_received(:puts).ordered.with("💡🎥🎬 Calculating a list of files to refactor...")
    end
  end

  context "when RubocopStats returns failure" do
    let(:rubocop_stats_fetch_result) { Failure("rubocop stats error") }

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("rubocop stats error")
    end

    it "puts to stdout" do
      subject
      expect(command).to have_received(:puts).ordered.with("💡 Running rubocop to get the list of offences to fix...")
      expect(command).not_to have_received(:puts).ordered.with("💡🎥 Checking git history since #{since} to find hot files...")
      expect(command).not_to have_received(:puts).ordered.with("💡🎥🎬 Calculating a list of files to refactor...")
    end
  end
end
