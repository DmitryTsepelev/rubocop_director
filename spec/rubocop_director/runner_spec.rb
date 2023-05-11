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

  before do
    allow(RubocopDirector::Commands::Plan).to receive(:new).and_return(plan_mock)
    allow(RubocopDirector::Commands::GenerateConfig).to receive(:new).and_return(generate_config_mock)

    allow(runner).to receive(:puts)
    allow(runner).to receive(:exit)
  end

  it "initializes plan without since" do
    subject
    expect(RubocopDirector::Commands::Plan).to have_received(:new).with(nil)
    expect(RubocopDirector::Commands::GenerateConfig).not_to have_received(:new)
  end

  it "prints successful message" do
    subject
    expect(runner).to have_received(:puts).with("plan success")
  end

  context "when plan returns failure" do
    let(:plan_run_result) { Failure("plan failure") }

    it "returns failure" do
      subject
      expect(RubocopDirector::Commands::Plan).to have_received(:new).with(nil)
      expect(RubocopDirector::Commands::GenerateConfig).not_to have_received(:new)
      expect(runner).to have_received(:puts).with("\nFailure: plan failure")
    end
  end

  context "when --since is passed" do
    let(:since) { "2023-01-01" }
    let(:args) { "--since=#{since}" }

    it "initializes plan with since" do
      subject
      expect(RubocopDirector::Commands::Plan).to have_received(:new).with(since)
    end
  end

  context "when --generate-config is passed" do
    let(:args) { "--generate-config" }

    it "initializes plan without since" do
      subject
      expect(RubocopDirector::Commands::Plan).not_to have_received(:new)
      expect(RubocopDirector::Commands::GenerateConfig).to have_received(:new)
    end

    it "prints successful message" do
      subject
      expect(runner).to have_received(:puts).with("generate config success")
    end

    context "when plan returns failure" do
      let(:generate_config_run_result) { Failure("generate config failure") }

      it "returns failure" do
        subject
        expect(RubocopDirector::Commands::Plan).not_to have_received(:new)
        expect(RubocopDirector::Commands::GenerateConfig).to have_received(:new)
        expect(runner).to have_received(:puts).with("\nFailure: generate config failure")
      end
    end
  end
end
