defmodule Rumbl.TestHelpers do
  alias Rumbl.{Multimedia, Accounts}
  
  def user_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "Some User",
      username: "#{System.unique_integer([:positive])}",
      password: attrs[:password] || "supersecret"
    })
    |> Accounts.register_user()
  end

  def video_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{
      title: "Some Video",
      url: "http://example.com",
      description: "A test video"
    })

    { :ok, video } = Multimedia.create_video(user, attrs)

    video
  end
end
