defmodule Dogma.ConfigTest do
  use ExUnit.Case, async: false
  use TemporaryEnv

  alias Dogma.Config
  alias Dogma.Rule

  @dummy_set Module.concat [__MODULE__, RuleSet]

  test "rule set is taken from the application env" do
    TemporaryEnv.set( :dogma, rule_set: @dummy_set ) do
      TemporaryEnv.delete( :dogma, :override ) do

        assert Config.build.rules == [
          %Rule.LineLength{},
        ]

      end
    end
  end

  test "rule set defaults to Dogma.RuleSet.All" do
    TemporaryEnv.delete( :dogma, :rule_set ) do
      TemporaryEnv.delete( :dogma, :override ) do

        assert Enum.sort(Dogma.RuleSet.All.rules) ==
          Enum.sort(Config.build.rules)

      end
    end
  end

  test "rules: overrides can be set in env" do
    TemporaryEnv.set( :dogma, rule_set: @dummy_set ) do
      TemporaryEnv.set(
        :dogma,
        override: [ %Rule.LineLength{max_length: 10} ]
      ) do

        assert Config.build.rules == [
          %Rule.LineLength{max_length: 10},
        ]

      end
    end
  end

  test "rules: overrides can add rules" do
    TemporaryEnv.set( :dogma, rule_set: @dummy_set ) do
      TemporaryEnv.set(
        :dogma,
        override: [ %Rule.ModuleDoc{enabled: false} ]
      ) do

        assert Config.build.rules == [
          %Rule.LineLength{},
          %Rule.ModuleDoc{enabled: false},
        ]

      end
    end
  end

  test "rules: legacy format is supported" do
    TemporaryEnv.set( :dogma, rule_set: @dummy_set ) do
      TemporaryEnv.set(
        :dogma,
        override: %{ ModuleDoc => [enabled: false] }
      ) do

        stdout = ExUnit.CaptureIO.capture_io(fn->
          rules = Config.build.rules
          assert rules == [
            %Rule.LineLength{},
            %Rule.ModuleDoc{enabled: false},
          ]
        end)
        assert stdout == """
        The Dogma rule override format used for ModuleDoc has been deprecated.

        Please update your config to use the new format like so:

        config :dogma,
          override: [
            %Dogma.Rule.ModuleDoc{enabled: false},
          ]

        https://github.com/lpil/dogma/blob/master/docs/configuration.md
        """
      end
    end
  end

  test "exclude comes from the application env" do
    TemporaryEnv.set( :dogma, exclude: [1, 2, 3] ) do
      assert Config.build.exclude == [1, 2, 3]
    end
  end

  test "exclude defaults to []" do
    TemporaryEnv.delete( :dogma, :exclude ) do
      assert [] == Config.build.exclude
    end
  end


  defmodule RuleSet do
    @behaviour Dogma.RuleSet
    def rules do
      [
        %Rule.LineLength{},
      ]
    end
  end
end
