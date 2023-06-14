RSpec.describe RubocopDirector::Commands::GenerateConfig do
  subject { command.run }

  let(:director_config_path) { Pathname.new(".rubocop_director.yml") }
  let(:todo_config_path) { ".rubocop_todo.yml" }
  let(:args) { {director_config: director_config_path} }
  let(:command) { described_class.new(**args) }

  let(:rubocop_todo_content) do
    {
      "Rails/SomeCop" => {
        "Exclude" => [
          "app/models/user.rb",
          "app/controller/user_controller.rb"
        ]
      }
    }
  end

  before do
    allow(File).to receive(:write)
  end

  context "when .rubocop_todo.yml exists" do
    before do
      allow(YAML).to receive(:load_file).with(todo_config_path).and_return(rubocop_todo_content)
    end

    it "returns success" do
      expect(subject).to be_success
      expect(subject.value!).to eq("Config generated")
    end

    it "creates file with config" do
      subject

      expect(File).to have_received(:write).with(
        director_config_path,
        "---\nupdate_weight: 1\ndefault_cop_weight: 1\nweights:\n  Rails/SomeCop: 1\n"
      )
    end

    context "when .rubocop-director.yml config is already generated" do
      before do
        allow(File).to receive(:file?).with(director_config_path).and_return(true)
      end

      context "when user wants to override the previous config" do
        before do
          allow($stdin).to receive_message_chain(:gets, :chomp).and_return("y")
        end

        it "overrides the previous config" do
          expect(subject).to be_success
          expect(subject.value!).to eq("Config generated")
        end
      end

      context "when user wants to preserve the previous config" do
        before do
          allow($stdin).to receive_message_chain(:gets, :chomp).and_return("n")
        end

        it "not creates a new file" do
          expect(subject).to be_failure
          expect(subject.failure).to eq("previous version of .rubocop_director.yml was preserved.")

          expect(File).not_to have_received(:write)
        end
      end
    end
  end

  context "when .rubocop_todo.yml not exists" do
    before do
      allow(YAML).to receive(:load_file).with(todo_config_path).and_raise(Errno::ENOENT)
    end

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq(".rubocop_todo.yml not found, generate it using `rubocop --regenerate-todo`")
    end

    it "not creates file with config" do
      subject

      expect(File).not_to have_received(:write)
    end
  end
end
