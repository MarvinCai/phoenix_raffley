defmodule PhoenixRaffley.RaffleAdmin do
  alias PhoenixRaffley.Repo
  alias PhoenixRaffley.Raffles
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

  def get_raffle!(id) do
    Repo.get(Raffle, id)
  end

  def update_raffle(%Raffle{} = raffle, attrs) do
    raffle
    |> Raffle.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, raffle} ->
        raffle = Repo.preload(raffle, [:charity, :winning_ticket])
        Raffles.broadcast(raffle.id, {:raffle_updated, raffle})
        {:ok, raffle}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def draw_winner(%Raffle{status: :closed} = raffle) do
    raffle = Repo.preload(raffle, :tickets)

    case raffle.tickets do
      [] ->
        {:error, "No tickets to draw"}
      tickets ->
        winner = Enum.random(tickets)
        {:ok, _} = update_raffle(raffle, %{winning_ticket_id: winner.id})
    end

  end

  def draw_winner(%Raffle{}) do
    {:error, "Raffle must be closed to draw a winner."}
  end

  def delete_raffle(%Raffle{} = raffle) do
    Repo.delete(raffle)
  end
end
