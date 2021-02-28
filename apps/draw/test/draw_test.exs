defmodule DrawTest do
  use Draw.DataCase

  alias Draw.Persistence

  describe "init_canvas/1" do
    test "initializes a new canvas" do
      assert {:ok, {_pid, id, canvas}} = Draw.init_canvas()

      db_canvas = Persistence.get_canvas!(id)
      assert db_canvas.fields == to_string(canvas)
    end

    test "initializes and loads canvas from database" do
      assert {:ok, db_canvas} =
               Persistence.create_canvas(%{width: 2, height: 2, fields: "AB\nCD\n"})

      assert {:ok, {_pid, id, canvas}} = Draw.init_canvas(db_canvas.id)
      assert id == db_canvas.id
      assert "AB\nCD\n" == to_string(canvas)
    end

    test "fails to initialize canvas because ID doesn't exist" do
      assert {:error, :not_found} == Draw.init_canvas(Ecto.UUID.generate())
    end

    test "fails to initialize canvas because of wrong data in database" do
      {:ok, db_canvas} = Persistence.create_canvas(%{width: 2, height: 2, fields: "ASD"})
      assert {:error, :wrong_format} == Draw.init_canvas(db_canvas.id)
    end
  end
end
