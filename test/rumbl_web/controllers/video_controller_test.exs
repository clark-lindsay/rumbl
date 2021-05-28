defmodule RumblWeb.VideoControllerTest do
 use RumblWeb.ConnCase, async: true

  alias Rumbl.Multimedia

  test "requires authentication for all actions", %{ conn: conn } do
    Enum.each([
      get(conn, Routes.video_path(conn, :new)),
      get(conn, Routes.video_path(conn, :index)),
      get(conn, Routes.video_path(conn, :show, "123")),
      get(conn, Routes.video_path(conn, :edit, "123")),
      put(conn, Routes.video_path(conn, :update, "123", %{})),
      post(conn, Routes.video_path(conn, :create, %{})),
      delete(conn, Routes.video_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  describe "with a logged in user" do
    @valid_attrs %{ title: "Title", url: "example.com", description: "testing..." }
    @invalid_attrs %{}

    setup %{ conn: conn, login_as: username } do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      { :ok, user: user, conn: conn }
    end

    @tag login_as: "max"

    test "lists all of a users videos on index", %{ conn: conn, user: user } do
      user_video = video_fixture(user, title: "funny cats")
      other_video = video_fixture(user_fixture(username: "other"), title: "another video")

      response = get(conn, Routes.video_path(conn, :index)) |> html_response(200)

      assert response =~ ~r/Listing Videos/
      assert response =~ user_video.title
      refute response =~ other_video.title
    end

    @tag login_as: "max"
    test "creates user video and redirects", %{ conn: conn, user: user } do
      create_conn = post conn, Routes.video_path(conn, :create), video: @valid_attrs

      assert %{ id: id } = redirected_params(create_conn)
      assert redirected_to(create_conn) == Routes.video_path(create_conn, :show, id)

      conn = get conn, Routes.video_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Video"

      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "max"
    test "does not create a video and renders error when attrs invalid", %{ conn: conn } do
      count_before = Enum.count(Multimedia.list_videos())
      create_conn = post conn, Routes.video_path(conn, :create), video: @invalid_attrs

      assert html_response(create_conn, 200) =~ "check the errors"
      assert Enum.count(Multimedia.list_videos()) == count_before
    end
  end
end
