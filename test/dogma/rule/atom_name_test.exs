defmodule Dogma.Rule.AtomNameTest do
  use RuleCase, for: AtomName

  should "not error for snake_case atoms" do
    script = """
    x = :hello
    x = :hello_world
    {:ok, :foo_bar}
    def foo(:what), do: :bar
    """ |> Script.parse!("")

    assert [] == Rule.test(@rule, script)
  end

  should "not error for uppercase atoms" do
    script = """
    x = :HTML
    {:ok, :FOO}
    """ |> Script.parse!("")

    assert [] == Rule.test(@rule, script)
  end

  should "error for non snake_case atoms" do
    script = """
    x = :Hello
    x = :helloWorld
    {:ok, :fooBar}
    def foo(:whatBar), do: :bar
    """ |> Script.parse!("")

    expected_errors = 1..4 |> Enum.to_list |> Enum.map(&error_on_line/1)
    assert expected_errors == Rule.test(@rule, script)
  end

  should "error for uppercase atoms if allow_uppercase is false" do
    rule = %{ @rule | allow_uppercase: false }
    script = """
    x = :HTML
    {:ok, :FOO}
    """ |> Script.parse!("")

    expected_errors = 1..2 |> Enum.to_list |> Enum.map(&error_on_line/1)
    assert expected_errors == Rule.test(rule, script)
  end

  defp error_on_line(line) do
    %Error{
      message:  "Atoms should be in snake_case",
      rule: AtomName,
      line: line
    }
  end

end
