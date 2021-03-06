defmodule Dogma.Rule.TakenNameTest do
  use RuleCase, for: TakenName
  use ShouldI

  defp lint(script) do
    script |> Script.parse!( "" ) |> fn s -> Rule.test(@rule, s) end.()
  end

  defp verify fn_name do
    errors = """
    defp #{fn_name} do
      :function_body
    end
    """ |> lint
    assert [error_on_line(1, fn_name)] == errors,
          "Sytax error: Name #{fn_name} can not be used"
  end

  should "allow function names which not overrides standard lib namespace." do
    errors = """
    def ok? do
      :function_body
    end
    """ |> lint
    assert [] == errors
  end

  should "error when function name overrides standard library." do
    errors = """
    def unless do
      :function_body
    end
    """ |> lint
    assert [error_on_line(1, :unless)] == errors
  end

  should "error when private function overrides standard library." do
    errors = """
    defp unless do
      :function_body
    end
    """ |> lint
    assert [error_on_line(1, :unless)] == errors
  end

  should "error when macro name overrides standard library." do
    errors = """
    defmacro require(clause, expression) do
      quote do
        if(!unquote(clause), do: unquote(expression))
      end
    end
    """ |> lint
    assert [error_on_line(1, :require)] == errors
  end

  should "verify keywords for syntax errors" do
    Enum.map(TakenName.all_keywords, fn(x) -> verify(x) end)
  end

  defp error_on_line(line, name) do
    %Error{
      line: Dogma.Script.line(line),
      message: "`#{name}` is already taken and overrides standard library",
      rule: TakenName
    }
  end

end
