defmodule PhoenixRaffleyWeb.RaffleLive.Show do
  use PhoenixRaffleyWeb, :live_view
  alias PhoenixRaffley.Raffles
  import PhoenixRaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "Mount")
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, uri, socket) do
    IO.inspect(self(), label: "Handle Params")
    raffle = Raffles.get_raffle(id)
    socket =
      socket
      |> assign(raffle: raffle)
      |> assign(:page_title, raffle.prize)
      |> assign(:featured_raffle, Raffles.featured_raffles(raffle))
    {:noreply, socket}
  end

  def render(assigns) do
    IO.inspect(self(), label: "Render")
    ~H"""
      <div class="raffle-show">
        <div class="raffle">
          <img src={@raffle.image_path} />
          <section>
            <.render_badge status={@raffle.status} />
            <header>
            <h2>{@raffle.prize}</h2>
            <div class="price">
              ${@raffle.ticket_price} / ticket
            </div>
            </header>
            <div class="description">
              {@raffle.description}
              </div>
          </section>
        </div>
        <div class="activity">
          <div class="left">
          </div>
          <div class="right">
            <.feature_raffles raffles={@featured_raffle} />
          </div>
        </div>
      </div>
    """
  end

  def feature_raffles(assigns) do
    ~H"""
    <section>
      <h4> Featured Raffles</h4>
      <ul class="raffles">
        <li :for={raffle <- @raffles}>
          <.link navigate={~p"/raffles/#{raffle.id}"}>
            <img src={raffle.image_path}> {raffle.prize}
          </.link>
        </li>
      </ul>
    </section>
    """
  end
end
