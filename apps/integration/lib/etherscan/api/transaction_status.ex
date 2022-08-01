defmodule Integration.EtherScan.Api.TransactionStatus do
  @moduledoc """
  Embedded schema to represent `Integration.EtherScan.Api.TransactionStatus`
  """

  use Ecto.Schema

  import Ecto.Changeset

  @optional_fields ~w(
    hash
    status
  )a

  @primary_key false
  embedded_schema do
    field(:hash, :string)
    field(:status, :boolean)
  end

  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @optional_fields)
  end

  def build(changeset) do
    apply_action(changeset, :build)
  end
end
