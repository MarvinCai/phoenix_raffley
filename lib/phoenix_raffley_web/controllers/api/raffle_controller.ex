defmodule PhoenixRaffleyWeb.Api.RaffleController do
  use PhoenixRaffleyWeb, :controller
  alias PhoenixRaffley.RaffleAdmin

  def index(conn, _params) do
    raffles = RaffleAdmin.list_raffles()

    render(conn, :index, raffles: raffles)
  end

  def show(conn, %{"id" => id}) do
    raffle = RaffleAdmin.get_raffle!(id)

    render(conn, :show, raffle: raffle)
  end

  def create(conn, %{"raffle" => raffle_params}) do
    case RaffleAdmin.create_raffle(raffle_params) do
      {:ok, raffle} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/raffles/#{raffle.id}")
        |> render(:show, raffle: raffle)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
end
