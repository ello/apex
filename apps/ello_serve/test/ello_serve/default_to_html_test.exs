defmodule Ello.Serve.DefaultToHTMLTest do
  use Ello.Serve.ConnCase
  alias Ello.Serve.DefaultToHTML

  test "adds */* accept header if not present", %{conn: conn} do
    conn = DefaultToHTML.call(conn, [])
    assert "*/*" in get_req_header(conn, "accepts")
  end

  test "adds text/html to accept header if text/* present", %{conn: conn} do
    conn = conn
           |> put_req_header("accepts", "text/*,application/xhtml+xml,application/xml,application/x-httpd-php")
           |> DefaultToHTML.call([])
    [accept] = get_req_header(conn, "accepts")
    assert accept == "text/html,application/xhtml+xml,application/xml,application/x-httpd-php"
  end

  test "leaves everything else alone", %{conn: conn} do
    chrome_defualt = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    conn = conn
           |> put_req_header("accepts", chrome_defualt)
           |> DefaultToHTML.call([])
    [accept] = get_req_header(conn, "accepts")
    assert accept == chrome_defualt
  end
end
