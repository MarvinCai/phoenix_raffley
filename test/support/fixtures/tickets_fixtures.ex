defmodule PhoenixRaffley.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixRaffley.Tickets` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        price: 42
      })
      |> PhoenixRaffley.Tickets.create_ticket()

    ticket
  end
end
