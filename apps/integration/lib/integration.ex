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

      @doc """
            build a url with params as query string

      ## Parameters

        - base_url: String that represents the base URL.
        - params: map containing parameters will be translated to query string.

      ## Examples

          iex> build_url("www.foo.com.br", %{"bar" => 2, "xyz" => "test"})
          "www.foo.com.br?bar=2&xyz=test"
      """
      @spec build_url(String.t(), map) :: String.t()
      def build_url(base_url, params) do
        Tesla.build_url(base_url, params)
      end

      @doc """
      build struct from a given module and params

      ## Parameters

        - params: map containing parameters will be used to build module
        - module: map representing module will be build

      ## Examples

      iex> build_struct(%{"hash" => "1111", "status" => true}, Integration.EtherScan.Api.TransactionStatus)
      {:ok,
      %Integration.EtherScan.Api.TransactionStatus{
        hash: "1111",
        status: true
      }}

      """
      @spec build_struct(map, map) :: String.t()
      def build_struct(params, module) do
        struct(module)
        |> module.changeset(params)
        |> module.build()
      end
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
