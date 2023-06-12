require "dry/monads"

RSpec.describe RubocopDirector::Runner do
  include Dry::Monads[:result]

  subject { runner.perform }

  let(:runner) { described_class.new(args) }

  let(:args) { "" }

  let(:plan_run_result) { Success("plan success") }
  let(:plan_mock) { OpenStruct.new(run: plan_run_result) }

  let(:generate_config_run_result) { Success("generate config success") }
  let(:generate_config_mock) { OpenStruct.new(run: generate_config_run_result) }

  let(:rubocop_config_name) { ".rubocop.yml" }
  let(:director_config_name) { ".rubocop_director.yml" }
  let(:todo_config_name) { ".rubocop_todo.yml" }

  let(:since) { nil }
  let(:generate_config) { nil }
  let(:director_path) { Pathname.new("./") + director_config_name }
  let(:rubocop_path) { Pathname.new("./") + rubocop_config_name }
  let(:todo_path) { Pathname.new("./") + todo_config_name }
  let(:options) do
    options = {
      generate_config: nil,
      director_config: director_path,
      rubocop_config: rubocop_path
    }
    options[:since] = since unless since.nil?

    options
  end

  before do
    allow(Bundler).to receive(:root).and_return(Pathname.new("./")) if defined?(Bundler)
    allow(Rails).to receive(:root).and_return(Pathname.new("./")) if defined?(Rails)
    allow(Dir).to receive(:pwd).and_return(Pathname.new("./"))

    allow(RubocopDirector::Commands::Plan).to receive(:new).with(**options.slice(:since, :director_config, :rubocop_config)).and_return(plan_mock)
    allow(RubocopDirector::Commands::GenerateConfig).to receive(:new).with(**options.slice(:director_config)).and_return(generate_config_mock)

    allow(runner).to receive(:puts)
    allow(runner).to receive(:exit)
  end

  # TODO: all positive testing AND 1 negative testing for each commands
  context "when --generate_config is passed" do
    let(:args) { "--generate_config" }

    it "initializes generate config" do
      subject
      expect(RubocopDirector::Commands::Plan).not_to have_received(:new)
      expect(RubocopDirector::Commands::GenerateConfig).to have_received(:new)
    end

    it "prints generate config successful message" do
      subject
      expect(runner).to have_received(:puts).with("generate config success")
    end
  end

  context "when --generate_config --director_config=PATH is passed" do
    let(:director_path) { Pathname.new("./.abc.yml") }
    let(:args) { ["--generate_config", "--director_config=./.abc.yml"] }

    it "initializes generate config with specified director_config path" do
      subject
      expect(RubocopDirector::Commands::Plan).not_to have_received(:new)
      expect(RubocopDirector::Commands::GenerateConfig).to have_received(:new)
    end

    it "prints generate config successful message" do
      subject
      expect(runner).to have_received(:puts).with("generate config success")
    end
  end

  context "when --generate_config is not passed" do
    context "when no additional path params are passed" do
      it "initializes plan with default values" do
        subject
        expect(RubocopDirector::Commands::GenerateConfig).not_to have_received(:new)
        expect(RubocopDirector::Commands::Plan).to have_received(:new)
      end

      it "prints plan successful message" do
        subject
        expect(runner).to have_received(:puts).with("plan success")
      end
    end
    context "when --since is passed" do
      let(:since) { Date.parse("2000-01-01") }
      let(:args) { "--since=2000-01-01" }

      it "initializes plan with default values" do
        subject
        expect(RubocopDirector::Commands::GenerateConfig).not_to have_received(:new)
        expect(RubocopDirector::Commands::Plan).to have_received(:new)
      end

      it "prints plan successful message" do
        subject
        expect(runner).to have_received(:puts).with("plan success")
      end
    end

    context "when --director_config=PATH is passed" do
      let(:director_path) { Pathname.new("./.abc.yml") }
      let(:args) { "--director_config=./.abc.yml" }

      it "initializes plan with passed director_config path" do
        subject
        expect(RubocopDirector::Commands::GenerateConfig).not_to have_received(:new)
        expect(RubocopDirector::Commands::Plan).to have_received(:new)
      end

      it "prints plan successful message" do
        subject
        expect(runner).to have_received(:puts).with("plan success")
      end
    end

    context "when --rubocop_config is passed" do
      let(:rubocop_path) { Pathname.new("./.xyz.yml") }
      let(:args) { "--rubocop_config=./.xyz.yml" }

      it "initializes plan with passed rubocop_config path" do
        subject
        expect(RubocopDirector::Commands::GenerateConfig).not_to have_received(:new)
        expect(RubocopDirector::Commands::Plan).to have_received(:new)
      end

      it "prints plan successful message" do
        subject
        expect(runner).to have_received(:puts).with("plan success")
      end
    end
  end
end
