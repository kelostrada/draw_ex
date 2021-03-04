defmodule DrawWeb.PageLive do
  @moduledoc false
  use DrawWeb, :live_view

  alias Draw.Engine.Canvas
  alias Phoenix.PubSub

  defmodule Form do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :type, Ecto.Enum, values: [:point, :rectangle, :flood_fill], default: :point
      field :fill, :string
      field :outline, :string
      field :width, :integer
      field :height, :integer
    end

    def changeset(params) do
      form = cast(%Form{}, params, ~w(type fill outline width height)a)

      form
      |> type_changeset(get_type(form))
      |> Map.put(:action, :insert)
    end

    defp type_changeset(form, :point) do
      form
      |> validate_required(~w(type fill)a)
      |> validate_length(:fill, min: 1, max: 1)
    end

    defp type_changeset(form, :rectangle) do
      form
      |> validate_required(~w(type width height)a)
      |> validate_length(:fill, max: 1)
      |> validate_length(:outline, max: 1)
      |> validate_number(:width, greater_than: 0)
      |> validate_number(:height, greater_than: 0)
    end

    defp type_changeset(form, :flood_fill) do
      form
      |> validate_required(~w(type fill)a)
      |> validate_length(:fill, min: 1, max: 1)
    end

    def get_type(form), do: get_field(form, :type)

    def get_fill(form), do: get_field(form, :fill)

    def get_outline(form), do: get_field(form, :outline)

    def get_width(form), do: get_field(form, :width)

    def get_height(form), do: get_field(form, :height)
  end

  @impl true
  def mount(params, _session, socket) do
    canvas_id = Map.get(params, "canvas_id")

    socket =
      socket
      |> fetch_canvas(canvas_id)
      |> assign_form()

    if canvas_id do
      {:ok, socket}
    else
      {:ok, push_redirect(socket, to: "/?canvas_id=#{socket.assigns.canvas_id}", replace: true)}
    end
  end

  defp fetch_canvas(socket, canvas_id) do
    {:ok, canvas_id} = Draw.init_canvas(canvas_id)
    PubSub.subscribe(Draw.PubSub, "canvas:#{canvas_id}")

    canvas = Draw.Server.get_canvas(canvas_id)

    socket
    |> assign(canvas: canvas)
    |> assign(canvas_id: canvas_id)
  end

  defp assign_form(socket) do
    assign(socket, form: Form.changeset(%{}))
  end

  @impl true
  def handle_info({:canvas_update, canvas}, socket) do
    {:noreply, assign(socket, canvas: canvas)}
  end

  @impl true
  def handle_event("set_options", %{"form" => form_params}, socket) do
    form = Form.changeset(form_params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("operation", %{"x" => x, "y" => y}, socket) do
    {x, _} = Integer.parse(x)
    {y, _} = Integer.parse(y)

    socket =
      socket
      |> clear_flash(:error)
      |> make_operation({x, y})

    {:noreply, socket}
  end

  defp make_operation(socket, point) do
    form = socket.assigns.form
    canvas_id = socket.assigns.canvas_id

    if form.valid? do
      case run_operation(form, point, canvas_id) do
        {:ok, canvas} ->
          assign(socket, canvas: canvas)

        {:error, error} ->
          put_flash(socket, :error, "Error: #{inspect(error)}")
      end
    else
      put_flash(socket, :error, "Please fix the options")
    end
  end

  defp run_operation(form, point, canvas_id) do
    case Form.get_type(form) do
      :point ->
        Draw.Server.draw_point(canvas_id, point, Form.get_fill(form))

      :rectangle ->
        fill = Form.get_fill(form)
        outline = Form.get_outline(form)
        width = Form.get_width(form)
        height = Form.get_height(form)
        Draw.Server.draw_rectangle(canvas_id, point, width, height, fill, outline)

      :flood_fill ->
        Draw.Server.flood_fill(canvas_id, point, Form.get_fill(form))
    end
  end
end
