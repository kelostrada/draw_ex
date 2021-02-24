defmodule Draw.Persistence.Canvas do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> validate_required([:width, :height, :fields])
  end
end
