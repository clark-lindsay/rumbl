defmodule RumblWeb.AuthTest do
  use RumblWeb.ConnCase, async: true
  alias RumblWeb.Auth

  setup %{conn: conn} do
    conn = conn
           |> bypass_through(RumblWeb.Router, :browser)
           |> get("/")
    { :ok, %{ conn: conn } }
  end

  test "`authenticate_user` halts the conn when there IS NO current_user", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
  end

  test "`authenticate_user` DOES NOT halt when there IS a current_user", %{conn: conn} do
    conn = conn |> assign(:current_user, user_fixture()) |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "`login` puts the user in the session", %{ conn: conn } do
    login_conn = conn
                   |> Auth.login(%Rumbl.Accounts.User{ id: 123 })
                   |> send_resp(:ok, "")
    next_conn = get(login_conn, "/")

    assert get_session(next_conn, :user_id) == 123
  end

  test "`logout` drops the session", %{ conn: conn } do
    logout_conn = conn
                   |> put_session(:user_id, 123)
                   |> Auth.logout()
                   |> send_resp(:ok, "")
    next_conn = get(logout_conn, "/")

    assert get_session(next_conn, :user_id) == nil
  end

  describe "the `call` function" do
    test "`call` places the user from session into assigns", %{ conn: conn } do
      user = user_fixture()
      conn = conn |> put_session(:user_id, user.id) |> Auth.call(Auth.init([]))

      assert conn.assigns.current_user.id == user.id
    end

    test "`call` with no session sets the current_user assign to nil", %{ conn: conn } do
      conn = conn  |> Auth.call(Auth.init([]))

      assert conn.assigns.current_user == nil
    end

  end
end
