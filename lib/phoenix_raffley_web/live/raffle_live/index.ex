defmodule PhoenixRaffleyWeb.RaffleLive.Index do
  use PhoenixRaffleyWeb, :live_view

  alias PhoenixRaffley.Raffles
  alias PhoenixRaffleyWeb.CustomComponents, as: Components

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "Mount")
    {:ok, socket }
  end

  def handle_params(params, uri, socket) do
    IO.inspect(self(), label: "Handle Params")

    socket =
      socket
        |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
        |> assign([form: to_form(params), page_title: "Raffley"])

    {:noreply, socket}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    IO.inspect(self(), label: "Render")
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

        <.link patch={~p"/raffles"} >
          Reset
        </.link>
      </.form>
    """
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status sort_by))
      |> Map.reject(fn {_, v} -> v == "" end)

    IO.inspect(params, label: "Filter Params")
      socket = push_patch(socket, to: ~p"/raffles?#{params}")
    {:noreply, socket}
  end
end
