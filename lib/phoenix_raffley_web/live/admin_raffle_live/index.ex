defmodule PhoenixRaffleyWeb.AdminRaffleLive.Index do
  use PhoenixRaffleyWeb, :live_view
  alias PhoenixRaffley.RaffleAdmin
  import PhoenixRaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Raffle Admin")
      |> stream(:raffles, RaffleAdmin.list_raffles(), reset: true)

      {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div class="admin-index">
        <.header>
          {@page_title}
        </.header>
        <.table id="raffles" rows={@streams.raffles}>
          <:col :let={{_dom_id, raffle}} label="Prize">
            <.link navigate={~p"/raffles/#{raffle.id}"}>
              {raffle.prize}
            </.link>
          </:col>

          <:col :let={{_dom_id, raffle}} label="Status">
            <.render_badge status={raffle.status}/>
          </:col>

          <:col :let={{_dom_id, raffle}} label="Ticket Price">
            {"$#{raffle.ticket_price}"}
          </:col>
        </.table>
      </div>
    """
  end
end
