defmodule PhoenixRaffley.CharitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixRaffley.Charities` context.
  """

  @doc """
  Generate a unique charity name.
  """
  def unique_charity_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique charity slug.
  """
  def unique_charity_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a charity.
  """
  def charity_fixture(attrs \\ %{}) do
    {:ok, charity} =
      attrs
      |> Enum.into(%{
        name: unique_charity_name(),
        slug: unique_charity_slug()
      })
      |> PhoenixRaffley.Charities.create_charity()

    charity
  end
end
