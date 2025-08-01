defmodule PhoenixRaffleyWeb.AdminRaffleLive.Form do
  alias PhoenixRaffley.RaffleAdmin
  alias PhoenixRaffley.Raffles.Raffle
  alias PhoenixRaffley.Charities
  use PhoenixRaffleyWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:charity_options, Charities.all_charity_names_and_ids())
      |> apply_action(socket.assigns.live_action, params)
    {:ok, socket}
  end

  defp apply_action(socket, :new, _params) do
    changeset = RaffleAdmin.change_raffle(%Raffle{})

    socket
    |> assign(:page_title, "New Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, %Raffle{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    raffle = RaffleAdmin.get_raffle!(id)
    changeset = RaffleAdmin.change_raffle(raffle)

    socket
    |> assign(:page_title, "Edit  Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
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

        <.input field={@form[:charity_id]} type="select" label="Charity"
        options={@charity_options} prompt="Choose a charity" />

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
      |> assign(:form, to_form(RaffleAdmin.change_raffle(socket.assigns.raffle, raffle_params), action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    save_raffle(socket, socket.assigns.live_action, raffle_params)
  end

  defp save_raffle(socket, :new, raffle_params) do
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

  defp save_raffle(socket, :edit, raffle_params) do
    case RaffleAdmin.update_raffle(socket.assigns.raffle, raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle update successfully!")
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
