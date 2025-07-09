defmodule PhoenixRaffleyWeb.RaffleLive.Index do
  use PhoenixRaffleyWeb, :live_view

  alias PhoenixRaffley.Raffles
  alias PhoenixRaffleyWeb.CustomComponents, as: Components

  def mount(_params, _session, socket) do
    socket = assign(socket, raffles: Raffles.list_raffles(), page_title: "Raffley")
    {:ok, socket }
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <Components.render_banner :if={false}>
        <:myslot :let={emoji}>
          <h1>
            <.icon name="hero-sparkles-solid" />
            Mystery Raffle Coming Soon! <%= emoji %>
          </h1>
        </:myslot>
        <:details>
          To be revealed tomorrow! Stay tuned for the big surprise!
        </:details>
      </Components.render_banner>
      <div class="raffles">
        <Components.render_raffle_card :for={raffle<- @raffles} raffle={raffle}/>
      </div>
    </div>
    """
  end
end
