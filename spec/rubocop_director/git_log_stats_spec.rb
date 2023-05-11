RSpec.describe RubocopDirector::GitLogStats do
  subject { described_class.new(since).fetch }

  let(:since) { "2023-01-01" }
  let(:command) do
    "git log --since=\"#{since}\" --pretty=format: --name-only | sort | uniq -c | sort -rg"
  end

  let(:stdout) { "" }
  let(:stderr) { "" }

  before do
    allow(Open3).to receive(:capture3).with(command).and_return([stdout, stderr])
  end

  context "when returns no errors" do
    let(:stdout) do
      <<~LOG
        2938
        136 config/locales/en.yml
        99 db/schema.rb
      LOG
    end

    it "returns success" do
      expect(subject).to be_success
      expect(subject.value!).to eq("config/locales/en.yml" => 136, "db/schema.rb" => 99)
    end
  end

  context "when returns errors" do
    let(:stderr) { "error" }

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("Failed to fetch git stats: #{stderr}")
    end
  end
end
