defmodule PhoenixRaffleyWeb.RaffleLive.Index do
  use PhoenixRaffleyWeb, :live_view

  alias PhoenixRaffley.Raffles
  alias PhoenixRaffleyWeb.CustomComponents, as: Components

  def mount(_params, _session, socket) do
    socket =
      socket
        |> stream(:raffles, Raffles.list_raffles())
        |> assign([form: to_form(%{}), page_title: "Raffley"])

    # IO.inspect(socket.assigns.streams.raffles, label: "MOUNT")

    # socket = attach_hook(socket, :post_mount, :after_render, fn socket ->
    #   IO.inspect(socket.assigns.streams.raffles, label: "AFTER RENDER")
    #   socket

    # end)
    {:ok, socket }
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
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
      <.render_filter_form form={@form} />
      <div class="raffles" id="raffles" phx-update="stream">
        <Components.render_raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id}/>
      </div>
    </div>
    """
  end

  attr :form, :map, required: true
  def render_filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter" >
        <.input field={@form["q"]} placeholder="Search..." autocomplete="off" phx-debounce="1000"/>
        <.input type="select" field={@form["status"]} options={["upcoming", "open", "closed"]} prompt="Status" />
        <.input type="select" field={@form["sort_by"]} options={[
          Prize: "price",
          "Price: High to low": "ticket_price_desc",
          "Price: Low to high": "ticket_price_asc"
          ]} prompt="Sort By" />
      </.form>
    """
  end

  def handle_event("filter", params, socket) do
    socket =
      socket
      |> assign(form: to_form(params))
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
    {:noreply, socket}
  end
end
