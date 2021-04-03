defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", user: Accounts.get_user(id))
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{ "user" => user_params }) do
    case Accounts.create_user(user_params) do
      { :ok, user } -> 
        conn
          |> put_flash(:info, "User #{user.name} created!")
          |> redirect(to: Routes.user_path(conn, :index))
      { :error, %Ecto.Changeset{} = changeset } -> 
        render(conn, "new.html", changeset: changeset)
    end
  end
end
