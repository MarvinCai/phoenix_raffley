defmodule PhoenixRaffleyWeb.RuleController do
  use PhoenixRaffleyWeb, :controller

  alias PhoenixRaffley.Rule

  def index(conn, _params) do
    emojis = ~w(😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚)
    |> Enum.random()
    |> String.duplicate(5)

    rules = Rule.list_rules()
    render(conn, :index, emoji: emojis, rules: rules)
  end

  def show(conn, %{"id" => id}) do
    rule = Rule.get_rule(id)

    render(conn, :show, rule: rule)
  end
end
