defmodule DrawWeb.PageLiveTest do
  use DrawWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/?canvas_id=" <> canvas_id}}} = live(conn, "/")
    {:ok, page_live, disconnected_html} = live(conn, "/?canvas_id=#{canvas_id}")
    assert disconnected_html =~ "Canvas"
    assert render(page_live) =~ "Canvas"
  end
end
