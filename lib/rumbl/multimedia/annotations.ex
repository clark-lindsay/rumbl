defmodule Rumbl.Multimedia.Annotations do
  use Ecto.Schema
  import Ecto.Changeset

  schema "annotations" do
    field :at, :integer
    field :body, :string
    field :user_id, :id
    field :video_id, :id

    timestamps()
  end

  @doc false
  def changeset(annotations, attrs) do
    annotations
    |> cast(attrs, [:body, :at])
    |> validate_required([:body, :at])
  end
end
