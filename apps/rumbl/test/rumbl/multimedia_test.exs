defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Video
  
  describe "categories" do
    test "lists categories in alphabetical order" do
      categories = ~w(Drama Comedy Action)
      for name <- categories do
        Multimedia.create_category!(name)
      end

      alpha_names = for %Category{ name: name } <-
        Multimedia.list_alphabetical_categories() do
        name
      end

      test_only_alpha_names = alpha_names
        |> Enum.filter(&(Enum.member?(categories, &1)))
      assert test_only_alpha_names == ~w(Action Comedy Drama)
    end
  end

  describe "videos" do
    @valid_attrs %{description: "desc", title: "title", url: "http://local"}
    @invalid_attrs %{ description: nil, title: nil, url: nil}

    test "list_videos/0 returns all videos" do
      owner = user_fixture()
      %Video{id: id1} = video_fixture(owner)

      assert [%Video{id: ^id1}] = Multimedia.list_videos()

      %Video{id: id2} = video_fixture(owner)

      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_videos()
    end

    test "get_video/1 returns the video with the given id" do
      owner = user_fixture()
      %Video{id: id} = video_fixture(owner)

      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "creat_video/2 with valid data creates a video" do
      { :ok, %Video{} = video } = Multimedia.create_video(user_fixture(), @valid_attrs)

      assert video.description == @valid_attrs.description
      assert video.title == @valid_attrs.title
      assert video.url == @valid_attrs.url
    end

    test "create_video/2 with invalid data returns a changeset" do
      assert { :error, %Ecto.Changeset{} } = Multimedia.create_video(user_fixture(), @invalid_attrs)
    end

    test "update_video/2 with valid data updates a video" do
      owner = user_fixture()
      video = video_fixture(owner)
      { :ok, %Video{} = video } = Multimedia.update_video(video, %{title: "updated title"})

      assert video.title == "updated title"
    end

    test "update_video/2 with invalid data returns a changeset and makes no update" do
      owner = user_fixture()
      %Video{id: id} = video = video_fixture(owner)

      assert { :error, %Ecto.Changeset{} } = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "delete_video/1 deletes the video" do
      owner = user_fixture()
      %Video{id: id} = video = video_fixture(owner)

      assert { :ok, %Video{id: ^id} } = Multimedia.delete_video(video)
      assert [] = Multimedia.list_videos()
    end

    test "change_video/2 returns a changeset" do
      owner = user_fixture()
      video = video_fixture(owner)

      assert %Ecto.Changeset{} = Multimedia.change_video(video, @valid_attrs)
    end
  end
end
