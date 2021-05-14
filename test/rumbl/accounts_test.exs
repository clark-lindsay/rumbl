defmodule Rumbl.AccountsTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  describe "register_user/1" do
    @valid_attrs %{
      name: "eva",
      username: "eva_online",
      password: "secret"
    }
    @invalid_attrs %{}

    test "with valid data, inserts user" do
      { :ok, %User{id: id} = user } = Accounts.register_user(@valid_attrs)

      assert user.name == "eva"
      assert user.username == "eva_online"
      assert [%User{ id: ^id }] = Accounts.list_users()
    end

    test "with invalid data, does not insert user" do
      assert { :error, _changeset } = Accounts.register_user(@invalid_attrs)
      assert Accounts.list_users() == []
    end
  end
end
