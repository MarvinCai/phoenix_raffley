defmodule PhoenixRaffley.Rule do

  def list_rules do
    [
      %{
        id: 1,
        text: "Work hard"
      },
      %{
        id: 2,
        text: "Play hard"
      },
      %{
        id: 3,
        text: "Have fun"
      },
    ]
  end

  def get_rule(id) when is_integer(id) do
    Enum.find(list_rules(), fn rule -> rule.id == id end)
  end

  def get_rule(id) when is_binary(id) do
    id |> String.to_integer |> get_rule
  end

end
