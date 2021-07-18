defmodule RumblWeb.UserViewTest do
  use RumblWeb.ConnCase, async: true
  import Phoenix.View

  test "index shows names of users", %{ conn: conn } do
    users = [
      %Rumbl.Accounts.User{
        name: "Alice",
        id: 1
      },
      %Rumbl.Accounts.User{
        name: "Alice",
        id: 1
      }
    ]

    content = render_to_string(RumblWeb.UserView, "index.html", conn: conn, users: users)

    assert String.contains?(content, "Listing Users")

    for user <- users do
      assert String.contains?(content, user.name)
    end
  end

  test "renders `new.html`", %{ conn: conn } do
    changeset = Rumbl.Accounts.change_user(%Rumbl.Accounts.User{})
    
    content = render_to_string(RumblWeb.UserView, "new.html", conn: conn, changeset: changeset)

    assert String.contains?(content, "New User")

    assert String.contains?(content, "Name")
    assert String.contains?(content, "Username")
  end
end
