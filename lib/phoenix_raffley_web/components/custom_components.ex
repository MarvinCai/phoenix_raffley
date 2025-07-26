defmodule PhoenixRaffleyWeb.CustomComponents do
  use PhoenixRaffleyWeb, :html
  alias PhoenixRaffley.Raffles.Raffle

  attr :raffle, Raffle, required: true
  attr :id, :string, required: true
  def render_raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle.id}"} id={@id}>
      <div class="card">
        <div class="charity">
          {@raffle.charity.name}
        </div>
        <img src={@raffle.image_path} />
        <h2>{@raffle.prize}</h2>
        <div class="details">
          <div class="price">
            {"$#{@raffle.ticket_price}"}
          </div>
          <.render_badge status={@raffle.status} />
        </div>
      </div>
    </.link>
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

  slot :detail
  slot :details
  @spec render_banner(map()) :: Phoenix.LiveView.Rendered.t()
  def render_banner(assigns) do
    assigns = assign(assigns, :emoji, ~w(🎉 🥳 🎊 ✨ ⚡️ 🔥 🌈 🎉 🥳 🎊 ✨ ⚡️ 🔥 🌈) |> Enum.random())
    ~H"""
    <div class="banner">
      {render_slot(@inner_block)}
      {render_slot(@detail, @emoji)}
      <div :if={@details != []} class="details">
        {render_slot(@details)}
      </div>
    </div>
    """
  end
end
