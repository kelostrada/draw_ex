defmodule Draw.Repo.Migrations.CreateCanvases do
  use Ecto.Migration

  def change do
    create table(:canvases, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :width, :integer
      add :height, :integer
      add :fields, :text

      timestamps()
    end
  end
end
