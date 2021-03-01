defmodule DrawTest do
  use Draw.DataCase

  alias Draw.Persistence

  describe "init_canvas/1" do
    test "initializes a new canvas" do
      assert {:ok, id} = Draw.init_canvas()
      assert Persistence.get_canvas!(id)
    end

    test "initializes and loads canvas from database" do
      assert {:ok, db_canvas} =
               Persistence.create_canvas(%{width: 2, height: 2, fields: "AB\nCD\n"})

      assert {:ok, id} = Draw.init_canvas(db_canvas.id)
      assert id == db_canvas.id
      assert "AB\nCD\n" == db_canvas.fields
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
