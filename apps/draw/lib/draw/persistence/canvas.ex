defmodule Draw.Persistence.Canvas do
  @moduledoc """
  Canvas database schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Draw.Persistence.Canvas{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "canvases" do
    field :fields, :string
    field :height, :integer
    field :width, :integer

    timestamps()
  end

  @doc false
  def changeset(canvas, attrs) do
    canvas
    |> cast(attrs, [:width, :height, :fields])
    |> validate_required([:width, :height, :fields], trim: false)
    |> validate_number(:width, greater_than: 0)
    |> validate_number(:height, greater_than: 0)
  end
end
