defmodule PhoenixRaffleyWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :phoenix_raffley,
    pubsub_server: PhoenixRaffley.PubSub

  def init(_opts) do
    # This function is called when the module is loaded.
    # You can use it to set up any initial state or configuration.
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {username, _presence} <- joins do
      presence = %{id: username, metas: Map.fetch!(presences, username)}

      Phoenix.PubSub.local_broadcast(PhoenixRaffley.PubSub, "updates:" <> topic, {:user_joined, presence})
    end

    for {username, _presence} <- leaves do
      metas =
        case Map.fetch(presences, username) do
          {:ok, metas} -> metas
          :error -> []
        end

      presence = %{id: username, metas: metas}

      Phoenix.PubSub.local_broadcast(PhoenixRaffley.PubSub, "updates:" <> topic, {:user_left, presence})
    end

    {:ok, state}
  end
end
