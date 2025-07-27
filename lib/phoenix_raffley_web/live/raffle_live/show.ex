defmodule PhoenixRaffleyWeb.RaffleLive.Show do
  use PhoenixRaffleyWeb, :live_view
  alias PhoenixRaffley.Raffles
  alias PhoenixRaffley.Tickets
  alias PhoenixRaffley.Tickets.Ticket
  alias PhoenixRaffleyWeb.Presence
  alias PhoenixRaffleyWeb.CustomComponents, as: Components

  on_mount {PhoenixRaffleyWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "Mount")
    changeset = Tickets.change_ticket(%Ticket{})
    socket = assign(socket, :form, to_form(changeset))
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    IO.inspect(self(), label: "Handle Params")

    if connected?(socket) do
      Raffles.subscribe(id)
      %{current_user: current_user} = socket.assigns

      if current_user do
        {:ok, _} = Presence.track(self(), topic(id), current_user.username, %{
          online_at: System.system_time(:second)
        })

        Phoenix.PubSub.subscribe(PhoenixRaffley.PubSub, "updates:" <> topic(id))
      end
    end

    presences = Presence.list(topic(id))
      |> Enum.map(fn {username, %{metas: metas}} ->
        %{id: username, metas: metas}
      end)

    raffle = Raffles.get_raffle!(id)
    tickets = Raffles.list_tickets(raffle)
    socket =
      socket
      |> assign(raffle: raffle)
      |> stream(:tickets, tickets)
      |> stream(:presences, presences)
      |> assign(:ticket_count, Enum.count(tickets))
      |> assign(:ticket_sum, Enum.sum_by(tickets, & &1.price))
      |> assign(:page_title, raffle.prize)
      |> assign_async(:featured_raffle, fn ->
        {:ok, %{featured_raffle: Raffles.featured_raffles(raffle)}}
      end)
    {:noreply, socket}
  end

  defp topic(id), do: "raffle_wathers:#{id}"

  def render(assigns) do
    IO.inspect(self(), label: "Render")
    ~H"""
      <div class="raffle-show">
      <Components.render_banner :if={@raffle.winning_ticket_id}>
        <h1>
        <.icon name="hero-sparkles-solid" />
        Ticket #{@raffle.winning_ticket_id} Wins!
        </h1>
        <:details>
          {@raffle.winning_ticket.comment}
        </:details>
      </Components.render_banner>
        <div class="raffle">
          <img src={@raffle.image_path} />
          <section>
            <Components.render_badge status={@raffle.status} />
            <header>
            <div>
              <h2>{@raffle.prize}</h2>
              <h3>{@raffle.charity.name}</h3>
            </div>
            <div class="price">
              ${@raffle.ticket_price} / ticket
            </div>
            </header>
            <div class="totals">
            {@ticket_count} tickets sold &bull; ${@ticket_sum} raised
            </div>
            <div class="description">
              {@raffle.description}
              </div>
          </section>
        </div>
        <div class="activity">
          <div class="left">
            <div :if={@raffle.status == :open}>
              <%= if @current_user do %>
                <.form for={@form} id="ticket-form" phx-change="validate" phx-submit="save">
                  <.input field={@form[:comment]} placeholder="Comment..." autofocus />
                  <.button>
                    Get A Ticket
                  </.button>
                </.form>
              <% else %>
                <.link href={~p"/users/log-in"} class="button">
                  Log In To Get A Ticket
                </.link>
              <% end %>
            </div>
            <div id="tickets" phx-update="stream">
              <.ticket :for={{dom_id, ticket} <- @streams.tickets}
              ticket={ticket}
              id={dom_id}/>
            </div>
          </div>
          <div class="right">
            <.feature_raffles raffles={@featured_raffle} />

            <.raffle_watchers :if={@current_user} presences={@streams.presences} />
          </div>
        </div>
      </div>
    """
  end

  attr :raffles, :list, required: true
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

  attr :presences, :list, required: true
  def raffle_watchers(assigns) do
    ~H"""
    <section>
      <h4>Who's here</h4>
      <ul class="presneces" id="raffle-watchers" phx-update="stream">
        <li :for={{dom_id, %{id: username, metas: metas}} <- @presences} id={dom_id}>
          <.icon name="hero-user-circle-solid" class="w-5 h-5" />
          {username} ({length(metas)})
        </li>
      </ul>
    </section>
    """
  end

  attr :ticket, Ticket, required: true
  attr :id, :string, required: true
  def ticket(assigns) do
    ~H"""
    <div class="ticket" id={@id}>
      <span class="timeline"> </span>
      <section>
        <div class="price-paid">
          ${@ticket.price}
        </div>
        <div>
          <span  class="username">
            {@ticket.user.username}
          </span>
          bought a ticket
          <blockquote>
            {@ticket.comment}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    socket =
      socket
      |> assign(form: to_form(Ticket.changeset(%Ticket{}, ticket_params), action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
      %{raffle: raffle, current_user: user} = socket.assigns

      case Tickets.create_ticket(raffle, user, ticket_params) do
        {:ok, ticket} ->

          socket =
            socket
            |> assign(:form, to_form(Tickets.change_ticket(%Ticket{})))

          {:noreply, socket}
        {:error, changeset} ->
          socket =
            socket
            |> assign(form: to_form(changeset))

          {:noreply, socket}
      end
  end

  def handle_info({:ticket_created, ticket}, socket) do
    socket =
      socket
      |> update(:ticket_count, &(&1 + 1))
      |> update(:ticket_sum, &(&1 + ticket.price))
      |> stream_insert(:tickets, ticket, at: 0)

     {:noreply, socket}
  end

  def handle_info({:raffle_updated, raffle}, socket) do
     {:noreply, assign(socket, raffle: raffle)}
  end

  def handle_info({:user_joined, presence}, socket) do
     {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({:user_left, presence}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
      else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end
end
