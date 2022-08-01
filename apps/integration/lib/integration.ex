defmodule Integration do
  @moduledoc """
  Documentation for `Integration`.
  """

  @doc """
  Default API
  """
  def default_api do
    quote do
      use Tesla

      @spec build_url(String.t(), map) :: String.t()
      def build_url(base_url, params) do
        Tesla.build_url(base_url, params)
      end

      @spec build_struct(map, map) :: String.t()
      def build_struct(params, schema) do
        struct(schema)
        |> schema.changeset(params)
        |> schema.build()
      end
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
