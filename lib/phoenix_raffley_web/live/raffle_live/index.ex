defmodule PhoenixRaffleyWeb.RaffleLive.Index do
  use PhoenixRaffleyWeb, :live_view

  alias PhoenixRaffley.Raffles
  alias PhoenixRaffleyWeb.CustomComponents, as: Components

  def mount(_params, _session, socket) do
    socket = assign(socket, :raffles, Raffles.list_raffles())
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <h1>Raffles</h1>
      <div class="raffles">
        <Components.render_raffle_card :for={raffle<- @raffles} raffle={raffle}/>
      </div>
    </div>
    """
  end
end
