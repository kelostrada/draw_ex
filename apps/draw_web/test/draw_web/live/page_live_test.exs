defmodule DrawWeb.PageLiveTest do
  use DrawWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Canvas"
    assert render(page_live) =~ "Canvas"
  end
end
