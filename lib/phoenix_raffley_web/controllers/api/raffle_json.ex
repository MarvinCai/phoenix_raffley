defmodule PhoenixRaffleyWeb.Api.RaffleJSON do

  def index(%{raffles: raffles}) do
    %{
      raffles:
        for raffle <- raffles do
          data(raffle)
        end
    }
  end

  def show(%{raffle: raffle}) do
    %{raffle: data(raffle)}
  end

  defp data(raffle) do
    %{
        id: raffle.id,
        prize: raffle.prize,
        description: raffle.description,
        ticket_price: raffle.ticket_price,
        charity_id: raffle.charity_id,
        status: raffle.status,
        image_path: raffle.image_path
      }
  end

  def error(%{changeset: changeset}) do
    error = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
      msg
    end)
    %{
      errors: error
    }
  end
end
