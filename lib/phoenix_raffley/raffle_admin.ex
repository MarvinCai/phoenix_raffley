defmodule PhoenixRaffley.RaffleAdmin do
  alias PhoenixRaffley.Repo
  alias PhoenixRaffley.Raffles.Raffle
  import Ecto.Query

  def list_raffles do
    from(Raffle)
    |> order_by([desc: :inserted_at])
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    %Raffle{}
    |> Raffle.changeset(attrs)
    |> Repo.insert()
  end

  def change_raffle(%Raffle{} = raffle, attrs \\ %{}) do
    raffle
    |> Raffle.changeset(attrs)
  end
end
