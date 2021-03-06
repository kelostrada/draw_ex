defmodule Draw.Persistence do
  @moduledoc """
  The Persistence context.
  """

  import Ecto.Query, warn: false
  alias Draw.Repo

  alias Draw.Persistence.Canvas

  @doc """
  Returns the list of canvases.

  ## Examples

      iex> list_canvases()
      [%Canvas{}, ...]

  """
  def list_canvases do
    Repo.all(Canvas)
  end

  @doc """
  Gets a single canvas.

  ## Examples

      iex> get_canvas(123)
      %Canvas{}

      iex> get_canvas(456)
      nil

  """
  def get_canvas(id), do: Repo.get(Canvas, id)

  @doc """
  Gets a single canvas.

  Raises `Ecto.NoResultsError` if the Canvas does not exist.

  ## Examples

      iex> get_canvas!(123)
      %Canvas{}

      iex> get_canvas!(456)
      ** (Ecto.NoResultsError)

  """
  def get_canvas!(id), do: Repo.get!(Canvas, id)

  @doc """
  Creates a canvas.

  ## Examples

      iex> create_canvas(%{field: value})
      {:ok, %Canvas{}}

      iex> create_canvas(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_canvas(attrs \\ %{}) do
    %Canvas{}
    |> Canvas.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates an empty canvas based on its Engine representation with default values.

  ## Examples

      iex> create_empty_canvas()
      {:ok, %Canvas{}}

      iex> create_empty_canvas({2, 3})
      {:ok, %Canvas{width: 2, height: 3}}
  """
  def create_empty_canvas(size \\ nil) do
    canvas = Draw.Engine.new_canvas(size)

    attrs = %{
      width: canvas.width,
      height: canvas.height,
      fields: to_string(canvas)
    }

    create_canvas(attrs)
  end

  @doc """
  Updates a canvas.

  ## Examples

      iex> update_canvas(canvas, %{field: new_value})
      {:ok, %Canvas{}}

      iex> update_canvas(canvas, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_canvas(%Canvas{} = canvas, attrs) do
    canvas
    |> Canvas.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a canvas.

  ## Examples

      iex> delete_canvas(canvas)
      {:ok, %Canvas{}}

      iex> delete_canvas(canvas)
      {:error, %Ecto.Changeset{}}

  """
  def delete_canvas(%Canvas{} = canvas) do
    Repo.delete(canvas)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking canvas changes.

  ## Examples

      iex> change_canvas(canvas)
      %Ecto.Changeset{data: %Canvas{}}

  """
  def change_canvas(%Canvas{} = canvas, attrs \\ %{}) do
    Canvas.changeset(canvas, attrs)
  end
end
