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
end
