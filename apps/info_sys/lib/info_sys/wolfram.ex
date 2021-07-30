defmodule InfoSys.Wolfram do
  import SweetXml
  @behaviour InfoSys.Backend

  @base "http://api.wolframalpha.com/v2/query"

  @impl true
  def name(), do: "Wolfram Alpha"

  @impl true
  def compute(query_str, _opts) do
    query_str
      |> fetch_xml()
      |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]/subpod/plaintext/text()" )
      |> build_results()
  end
  
  defp fetch_xml(query_str) do
    { :ok, { _, _, body } } = :httpc.request(String.to_charlist(url(query_str)))

    body
  end

  defp build_results(nil), do: []
  defp build_results(answer) do
    [%InfoSys.Result{ backend: __MODULE__, score: 95, text: to_string(answer) }]
  end

  defp url(query_str) do
    "#{@base}?" <> URI.encode_query(appid: id(), input: query_str, format: "plaintext")
  end

  defp id(), do: Application.fetch_env!(:info_sys, :wolfram)[:app_id]
end
