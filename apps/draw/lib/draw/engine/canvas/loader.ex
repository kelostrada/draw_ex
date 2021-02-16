defmodule Draw.Engine.Canvas.Loader do
  @moduledoc """
  Loader for Canvas. Helper functions used to parse data from canvas string representation
  """
  alias Draw.Engine.Canvas

  @doc """
  Loads canvas based on its string representation

  # Examples

  iex> Loader.load(2, 1, "AB\\n")
  {:ok, %Canvas{
    width: 2,
    height: 1,
    fields: %{{0, 0} => 65, {1, 0} => 66}
  }}
  """
  @spec load(integer(), integer(), String.t()) :: {:ok, Canvas.t()} | {:error, :wrong_format}
  def load(width, height, fields) do
    rows = fields |> String.split("\n") |> Enum.filter(&(&1 != ""))

    cond do
      length(rows) != height ->
        {:error, :wrong_format}

      Enum.any?(rows, &(String.length(&1) != width)) ->
        {:error, :wrong_format}

      true ->
        fields = prepare_fields(rows)

        {:ok, %Canvas{fields: fields, height: height, width: width}}
    end
  end

  defp prepare_fields(rows) do
    rows
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, j} ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {<<char>>, i} ->
        {{i, j}, char}
      end)
    end)
    |> Enum.into(%{})
  end
end
