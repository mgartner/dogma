use Dogma.RuleBuilder

defrule Dogma.Rule.AtomName, [allow_uppercase: true] do
  @moduledoc """
  A rule that disallows atom names not in `snake_case` or `SNAKE_CASE`.

  Good:

      status = :good_to_go
      format = :HTML
      {:ok, :green_light} = light

  Bad:

      status = :goodToGo
      {:ok, :greenLight} = light

  Th `SNAKE_CASE` format can be disallowed with `max_length` option set to `false`.
  """

  alias Dogma.Util.Name

  def test(rule, script) do
    script.tokens
    |> Enum.reject(&valid_token?(&1, rule.allow_uppercase))
    |> Enum.map(&error/1)
  end

  defp valid_token?({:atom, _, atom}, allow_uppercase) do
    atom_string = to_string(atom)
    (allow_uppercase and Name.upper_snake_case?(atom_string)) or
      Name.snake_case?(atom_string)
  end

  defp valid_token?(_, _), do: true

  defp error({_, line, _}) do
    %Error{
      rule:    __MODULE__,
      message: "Atoms should be in snake_case",
      line:    Dogma.Script.line(line),
    }
  end

end
