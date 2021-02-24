defmodule Draw.PersistenceTest do
  use Draw.DataCase

  alias Draw.Persistence

  describe "canvases" do
    alias Draw.Persistence.Canvas

    @valid_attrs %{fields: "some fields", height: 42, width: 42}
    @update_attrs %{fields: "some updated fields", height: 43, width: 43}
    @invalid_attrs %{fields: nil, height: nil, width: nil}

    def canvas_fixture(attrs \\ %{}) do
      {:ok, canvas} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Persistence.create_canvas()

      canvas
    end

    test "list_canvases/0 returns all canvases" do
      canvas = canvas_fixture()
      assert Persistence.list_canvases() == [canvas]
    end

    test "get_canvas!/1 returns the canvas with given id" do
      canvas = canvas_fixture()
      assert Persistence.get_canvas!(canvas.id) == canvas
    end

    test "create_canvas/1 with valid data creates a canvas" do
      assert {:ok, %Canvas{} = canvas} = Persistence.create_canvas(@valid_attrs)
      assert canvas.fields == "some fields"
      assert canvas.height == 42
      assert canvas.width == 42
    end

    test "create_canvas/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_canvas(@invalid_attrs)
    end

    test "create_canvas/1 with no positive size returns error changeset" do
      assert {:error, changeset} =
               Persistence.create_canvas(%{fields: "aaa", width: 0, height: 0})

      assert [
               height:
                 {"must be greater than %{number}",
                  [validation: :number, kind: :greater_than, number: 0]},
               width:
                 {"must be greater than %{number}",
                  [validation: :number, kind: :greater_than, number: 0]}
             ] == changeset.errors
    end

    test "update_canvas/2 with valid data updates the canvas" do
      canvas = canvas_fixture()
      assert {:ok, %Canvas{} = canvas} = Persistence.update_canvas(canvas, @update_attrs)
      assert canvas.fields == "some updated fields"
      assert canvas.height == 43
      assert canvas.width == 43
    end

    test "update_canvas/2 with invalid data returns error changeset" do
      canvas = canvas_fixture()
      assert {:error, %Ecto.Changeset{}} = Persistence.update_canvas(canvas, @invalid_attrs)
      assert canvas == Persistence.get_canvas!(canvas.id)
    end

    test "delete_canvas/1 deletes the canvas" do
      canvas = canvas_fixture()
      assert {:ok, %Canvas{}} = Persistence.delete_canvas(canvas)
      assert_raise Ecto.NoResultsError, fn -> Persistence.get_canvas!(canvas.id) end
    end

    test "change_canvas/1 returns a canvas changeset" do
      canvas = canvas_fixture()
      assert %Ecto.Changeset{} = Persistence.change_canvas(canvas)
    end
  end
end
