defmodule PhoenixRaffley.Raffles do
  alias PhoenixRaffley.Repo
  alias PhoenixRaffley.Raffles.Raffle
  def list_raffles() do
    Repo.all(Raffle)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def featured_raffles(raffle) do
    list_raffles()
    |> Enum.filter(&(&1.id != raffle.id))
  end
end
