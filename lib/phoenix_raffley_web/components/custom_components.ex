defmodule PhoenixRaffleyWeb.CustomComponents do
  use PhoenixRaffleyWeb, :html

  attr :raffle, PhoenixRaffley.Raffle, required: true
  def render_raffle_card(assigns) do
    ~H"""
    <div class="card">
      <img src={@raffle.image_path} />
      <h2><%= @raffle.prize %></h2>
      <div class="details">
        <div class="price">
          <%= "$#{@raffle.ticket_price}" %>
        </div>
        <.render_badge status={@raffle.status} />
      </div>
    </div>
    """
  end

  attr :status, :atom, values: [:upcoming, :open, :closed], default: :upcoming
  attr :class, :string, default: nil
  def render_badge(assigns) do
    ~H"""
    <dev class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status == :open && "text-lime-600 border-lime-600",
      @status == :upcoming && "text-amber-600 border-amber-600",
      @status == :closed && "text-grey-600 border-grey-600",
      @class
    ]}>
      <%= @status %>
    </dev>
    """
  end
end
