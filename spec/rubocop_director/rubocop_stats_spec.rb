RSpec.describe RubocopDirector::RubocopStats do
  subject { described_class.new.fetch }

  let(:since) { "2023-01-01" }

  let(:sed_command) { "sed '/todo/d' ./.rubocop.yml > tmpfile; mv tmpfile ./.rubocop.yml" }
  let(:sed_stdout) { "" }
  let(:sed_stderr) { "" }

  let(:rubocop_command) { "bundle exec rubocop --format json" }
  let(:rubocop_stdout) { "" }
  let(:rubocop_stderr) { "" }

  let(:checkout_command) { "git checkout ./.rubocop.yml" }

  before do
    allow(Open3).to receive(:capture3).with(sed_command).and_return([sed_stdout, sed_stderr])
    allow(Open3).to receive(:capture3).with(rubocop_command).and_return([rubocop_stdout, rubocop_stderr])
    allow(Open3).to receive(:capture3).with(checkout_command)
  end

  context "when sed returns errors" do
    let(:sed_stderr) { "error" }

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("Failed to remove TODO from rubocop config: #{sed_stderr}")
    end

    it "not runs rubocop command" do
      subject
      expect(Open3).not_to have_received(:capture3).with(rubocop_command)
    end
  end

  context "when rubocop returns no errors" do
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

    it "runs sed command" do
      subject
      expect(Open3).to have_received(:capture3).with(sed_command)
    end

    it "runs checkout command" do
      subject
      expect(Open3).to have_received(:capture3).with(checkout_command)
    end
  end

  context "when rubocop returns errors" do
    let(:rubocop_stderr) { "error" }

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("Failed to fetch rubocop stats: #{rubocop_stderr}")
    end

    it "runs sed command" do
      subject
      expect(Open3).to have_received(:capture3).with(sed_command)
    end

    it "runs checkout command" do
      subject
      expect(Open3).to have_received(:capture3).with(checkout_command)
    end
  end
end
