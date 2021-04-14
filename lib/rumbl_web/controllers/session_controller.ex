defmodule RumblWeb.SessionController do
  use RumblWeb, :controller

  alias RumblWeb.Auth
  alias Rumbl.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{ "session" => %{ "username" => username, "password" => password } }) do
    case Accounts.authenticate_by_username_and_pass(username, password) do
      { :ok, user } ->
        conn 
          |> Auth.login(user)
          |> put_flash(:info, "Welcome back!")
          |> redirect(to: Routes.page_path(conn, :index))
      { :error, _reason } ->
        conn 
          |> put_flash(:error, "Invalid username and password combination")
          |> render("new.html")
    end
  end
end
