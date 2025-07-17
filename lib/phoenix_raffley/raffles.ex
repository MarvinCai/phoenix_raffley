defmodule PhoenixRaffley.Raffles do
  alias PhoenixRaffley.Repo
  alias PhoenixRaffley.Raffles.Raffle
  import Ecto.Query
  def list_raffles() do
    Repo.all(Raffle)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def filter_raffles(filter) do
    from(Raffle)
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> sort(filter["sort_by"])
    |> Repo.all
  end

  defp with_status(query, status) when status in ~W(open closed upcoming) do
    where(query, status: ^status)
  end

  defp with_status(query, _status) do
   query
  end

  defp search_by(query, q) when q in ["", nil] do
    query
  end

  defp search_by(query, q) do
    where(query, [r], ilike(r.prize, ^"%#{q}%"))
  end

  defp sort(query, "prize") do
    order_by(query, :prize)
  end

  defp sort(query, "ticket_price_desc") do
    order_by(query, [desc: :ticket_price])
  end

  defp sort(query, "ticket_price_asc") do
    order_by(query, :ticket_price)
  end

  defp sort(query, _sort_by) do
    order_by(query, :id)
  end

  def featured_raffles(raffle) do
    Process.sleep(2000)

    from(Raffle)
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
