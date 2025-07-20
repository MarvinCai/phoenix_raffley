defmodule PhoenixRaffleyWeb.RaffleLive.Show do
  use PhoenixRaffleyWeb, :live_view
  alias PhoenixRaffley.Raffles
  import PhoenixRaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "Mount")
    {:ok, socket}
  end

  @spec handle_params(map(), any(), any()) :: {:noreply, map()}
  def handle_params(%{"id" => id}, _uri, socket) do
    IO.inspect(self(), label: "Handle Params")
    raffle = Raffles.get_raffle!(id)
    socket =
      socket
      |> assign(raffle: raffle)
      |> assign(:page_title, raffle.prize)
      |> assign_async(:featured_raffle, fn ->
        {:ok, %{featured_raffle: Raffles.featured_raffles(raffle)}}
      end)
    {:noreply, socket}
  end

  def render(assigns) do
    IO.inspect(self(), label: "Render")
    ~H"""
      <pre :if={false}>
        {inspect(@featured_raffle, pretty: true)})}
      </pre>
      <div class="raffle-show">
        <div class="raffle">
          <img src={@raffle.image_path} />
          <section>
            <.render_badge status={@raffle.status} />
            <header>
            <div>
              <h2>{@raffle.prize}</h2>
              <h3>{@raffle.charity.name}</h3>
            </div>
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
      <.async_result :let={result} assign={@raffles}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <ul class="raffles">
          <li :for={raffle <- result}>
            <.link navigate={~p"/raffles/#{raffle.id}"}>
              <img src={raffle.image_path}> {raffle.prize}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
