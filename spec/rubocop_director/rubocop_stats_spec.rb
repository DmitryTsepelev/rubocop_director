RSpec.describe RubocopDirector::RubocopStats do
  subject { command.fetch }

  let(:rubocop_config_path) { Pathname.new(".rubocop.yml") }
  let(:args) { rubocop_config_path }
  let(:command) { described_class.new(args) }

  let(:tmp_config_path) { "./.temp_rubocop.yml" }
  let(:config_json) { {some_config: "anything"} }
  let(:rubocop_command) { "bundle exec rubocop -c #{tmp_config_path} --format json" }
  let(:rubocop_stdout) { "" }
  let(:rubocop_stderr) { "" }

  before do
    allow(YAML).to receive(:load_file).with(rubocop_config_path).and_return(config_json)
    allow(File).to receive(:write).with(tmp_config_path, config_json.to_yaml)
    allow(Open3).to receive(:capture3).with(rubocop_command).and_return([rubocop_stdout, rubocop_stderr])
    allow(File).to receive(:delete).with(tmp_config_path)
  end

  context "when initial config is not loaded" do
    before do
      expect(YAML).to receive(:load_file).with(rubocop_config_path).and_raise(Errno::ENOENT)
    end

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("unable to load rubocop config. Please ensure .rubocop.yml file is present at your project's root directory")
    end
  end

  context "when temp config is not created" do
    before do
      allow(File).to receive(:write).with(tmp_config_path, config_json.to_yaml).and_raise IOError
    end

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("Failed to create a temporary config file to generate stats: IOError")
    end

    it "does not run rubocop command" do
      expect(Open3).not_to have_received(:capture3).with(rubocop_command)
    end
  end

  context "when stats are not generated" do
    let(:rubocop_stderr) { "some error" }

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("Failed to fetch rubocop stats: #{rubocop_stderr}")
    end
  end

  context "when stats are generated" do
    let(:rubocop_stdout) do
      "{\"files\":[{\"path\":\"app/models/user.rb\",\"offenses\":[{\"severity\":\"convention\",\"message\":\"Some error\",\"cop_name\":\"Rails/SomeCop\",\"corrected\":false,\"correctable\":false,\"location\":{\"start_line\":83,\"start_column\":55,\"last_line\":83,\"last_column\":76,\"length\":22,\"line\":83,\"column\":55}}]}]}"
    end

    it "returns success" do
      expect(subject).to be_success
      expect(subject.value!).to eq(
        [
          {
            "offenses" =>
              [
                {
                  "cop_name" => "Rails/SomeCop",
                  "correctable" => false,
                  "corrected" => false,
                  "location" => {
                    "column" => 55,
                    "last_column" => 76,
                    "last_line" => 83,
                    "length" => 22,
                    "line" => 83,
                    "start_column" => 55,
                    "start_line" => 83
                  },
                  "message" => "Some error",
                  "severity" => "convention"
                }
              ],
            "path" => "app/models/user.rb"
          }
        ]
      )
    end
  end
end
