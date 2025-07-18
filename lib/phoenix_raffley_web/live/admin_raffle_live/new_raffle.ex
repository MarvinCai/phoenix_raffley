defmodule PhoenixRaffleyWeb.AdminRaffleLive.NewRaffle do
  alias PhoenixRaffley.RaffleAdmin
  alias PhoenixRaffley.Raffles.Raffle
  use PhoenixRaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    changeset = RaffleAdmin.change_raffle(%Raffle{})

    socket =
      socket
      |> assign(:page_title, "New Raffle")
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        {@page_title}
      </.header>

      <.simple_form for={@form} id="raffle-form" phx-submit="save" phx-change="validate">
        <.input field={@form[:prize]} label="Prize"/>

        <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur"/>

        <.input field={@form[:ticket_price]} type="number" label="Ticket Price"/>

        <.input field={@form[:status]} type="select" label="Status"
        options={["upcoming", "open", "closed"]} prompt="Select Status" />

        <.input field={@form[:image_path]} label="Image Path"/>

        <:actions>
          <.button phx-disable-with="Saving..."> Save Raffle </.button>
        </:actions>

        <.back navigate={~p"/admin/raffles"}>
          Back
        </.back>
      </.simple_form>
    """
  end

  def handle_event("validate", %{"raffle" => raffle_params}, socket) do

    socket =
      socket
      |> assign(:form, to_form(RaffleAdmin.change_raffle(%Raffle{}, raffle_params), action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    case RaffleAdmin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle created successfully!")
          |> push_navigate(to: ~p"/admin/raffles")
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))
        {:noreply, socket}
    end
  end
end
