RSpec.describe RubocopDirector::OutputFormatter do
  subject { described_class.new(ranged_files: ranged_files, since: since).call }

  let(:since) { "2023-01-01" }
  let(:ranged_files) do
    [
      {
        path: "app/models/user.rb",
        updates_count: 2,
        offense_counts: {
          "Rails/SomeCop" => 2,
          "Rails/AnotherCop" => 3
        },
        value: 15
      },
      {
        path: "app/controllers/user_controller.rb",
        updates_count: 3,
        offense_counts: {
          "Rails/SomeCop" => 3
        },
        value: 5
      }
    ]
  end

  it "returns files" do
    expect(subject).to be_success

    expect(subject.value!).to eq(
      [
        "--------------------",
        "app/models/user.rb",
        "updated 2 times since 2023-01-01",
        "offences: Rails/SomeCop - 2, Rails/AnotherCop - 3",
        "refactoring value: 15 (75.0%)",
        "--------------------",
        "app/controllers/user_controller.rb",
        "updated 3 times since 2023-01-01",
        "offences: Rails/SomeCop - 3",
        "refactoring value: 5 (25.0%)"
      ]
    )
  end
end
