RSpec.describe RubocopDirector::FileStatsBuilder do
  subject do
    described_class.new(
      rubocop_json: rubocop_json,
      update_counts: update_counts,
      config: config
    ).build
  end

  let(:rubocop_json) do
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
        "path" => "app/controller/user_controller.rb"
      }
    ]
  end

  let(:update_counts) do
    {
      "app/models/user.rb" => 5,
      "app/controller/user_controller.rb" => 2
    }
  end

  let(:config) do
    {
      "default_cop_weight" => 0.2,
      "update_weight" => 0.3,
      "weights" => {
        "Rails/SomeCop" => 1,
        "Rails/AnotherCop" => 0.5
      }
    }
  end

  it "returns success" do
    expect(subject).to be_success
    expect(subject.value!).to eq(
      [
        {
          path: "app/models/user.rb",
          updates_count: 5,
          offense_counts: {"Rails/SomeCop" => 1, "Rails/AnotherCop" => 1},
          value: 2.25
        },
        {
          path: "app/controller/user_controller.rb",
          updates_count: 2,
          offense_counts: {"Rails/SomeCop" => 2},
          value: 1.2
        }
      ]
    )
  end

  context "when cop has no update_weight" do
    let(:config) do
      {
        "default_cop_weight" => 0.2,
        "weights" => {
          "Rails/SomeCop" => 1,
          "Rails/AnotherCop" => 0.5
        }
      }
    end

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq("`update_weight` is not configured")
    end
  end

  context "when cop has no weight" do
    let(:config) do
      {
        "default_cop_weight" => 0.2,
        "update_weight" => 0.3,
        "weights" => {
          "Rails/AnotherCop" => 0.5
        }
      }
    end

    it "uses default_cop_weight" do
      expect(subject).to be_success
      expect(subject.value!).to eq(
        [
          {
            path: "app/models/user.rb",
            updates_count: 5,
            offense_counts: {"Rails/SomeCop" => 1, "Rails/AnotherCop" => 1},
            value: 1.05
          },
          {
            path: "app/controller/user_controller.rb",
            updates_count: 2,
            offense_counts: {"Rails/SomeCop" => 2},
            value: 0.24
          }
        ]
      )
    end

    context "when there's no default_cop_weight" do
      let(:config) do
        {
          "update_weight" => 0.3,
          "weights" => {
            "Rails/AnotherCop" => 0.5
          }
        }
      end

      it "returns failure" do
        expect(subject).to be_failure
        expect(subject.failure).to eq("could not find weight for Rails/SomeCop and `default_cop_weight` is not configured")
      end
    end
  end
end
