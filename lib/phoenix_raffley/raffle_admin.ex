defmodule PhoenixRaffley.RaffleAdmin do
  alias PhoenixRaffley.Repo
  alias PhoenixRaffley.Raffles.Raffle
  import Ecto.Query

  def list_raffles do
    from(Raffle)
    |> order_by([desc: :inserted_at])
    |> Repo.all()
  end
end
