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
        <.button phx-click={JS.toggle(to: "#joke", in: "fade-in", out: "fade-out")}>
          Toggle Joke
        </.button>
        <div id="joke" class="joke">
          What's a tres's favorite drink, {@current_user.username}?
        </div>
        <.header>
          {@page_title}
          <:actions>
            <.link navigate={~p"/admin/raffles/new"} class="button">
              New Raffle
            </.link>
          </:actions>
        </.header>
        <.table id="raffles"
          rows={@streams.raffles}
          row_click={fn {_, raffle} -> JS.navigate(~p"/raffles/#{raffle.id}") end} >
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

          <:col :let={{_dom_id, raffle}} label="Winning Ticket #">
            {"#{raffle.winning_ticket_id}"}
          </:col>

          <:action :let={{_dom_id, raffle}}>
            <.link navigate={~p"/admin/raffles/#{raffle.id}/edit"}>
              Edit
            </.link>
          </:action>

          <:action :let={{dom_id, raffle}}>
            <.link phx-click={deletet_and_hide(dom_id, raffle)} phx-disable-with="Deleting..." data-confirm="Are you sure?">
              Delete
            </.link>
          </:action>

          <:action :let={{_dom_id, raffle}}>
            <.link phx-click="draw_a_winner" phx-value-id={raffle.id}>
              Draw Winner
            </.link>
          </:action>
        </.table>
      </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    raffle = RaffleAdmin.get_raffle!(id)
    {:ok, _} = RaffleAdmin.delete_raffle(raffle)

    Process.sleep(2000)

    {:noreply, stream_delete(socket, :raffles, raffle)}
  end

  def handle_event("draw_a_winner", %{"id" => id}, socket) do
    raffle = RaffleAdmin.get_raffle!(id)
    case RaffleAdmin.draw_winner(raffle) do
      {:ok, raffle} ->
        socket =
          socket
          |> put_flash(:info, "Winner drawn!")
          |> stream_insert(:raffles, raffle)
        {:noreply, socket}
      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def deletet_and_hide(dom_id, raffle) do
    JS.push("delete", value: %{id: raffle.id})
    |> JS.add_class("opacity-30", to: "##{dom_id}")
  end
end
