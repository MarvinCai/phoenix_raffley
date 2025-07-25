defmodule PhoenixRaffley.Raffles do
  alias PhoenixRaffley.Repo
  alias PhoenixRaffley.Raffles.Raffle
  alias PhoenixRaffley.Tickets.Ticket
  alias PhoenixRaffley.Charities.Charity
  import Ecto.Query
  def list_raffles() do
    Repo.all(Raffle)
  end

  @spec get_raffle!(any()) :: nil | [%{optional(atom()) => any()}] | %{optional(atom()) => any()}
  def get_raffle!(id) do
    Repo.get!(Raffle, id)
    |> Repo.preload(:charity)
  end

  def list_tickets(raffle) do
    raffle
    |> Ecto.assoc(:tickets)
    |> preload(:user)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def filter_raffles(filter) do
    from(Raffle)
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_charity(filter["charity"])
    |> sort(filter["sort_by"])
    |> preload(:charity)
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

  defp with_charity(query, slug) when slug in ["", nil], do: query

  defp with_charity(query, slug) do
    query
    |> join(:inner, [r], c in Charity, on: r.charity_id == c.id)
    |> where([r, c], c.slug == ^slug)
    |> preload([r, c], charity: c)
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

  defp sort(query, "charity") do
    query
    |> join(:inner, [r], c in assoc(r, :charity))
    |> order_by([r, c], c.name)
  end

  defp sort(query, _sort_by) do
    order_by(query, :id)
  end

  def featured_raffles(raffle) do
    from(Raffle)
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
