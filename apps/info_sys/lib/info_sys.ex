alias InfoSys.Cache

defmodule InfoSys do
  @backends [InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, backend: nil
  end

  def compute(query, opts \\ []) do
    opts = Keyword.put_new(opts, :limit, 10)
    timeout = opts[:timeout] || 10_000
    backends = opts[:backend] || @backends

    { uncached_backends, cached_results } = fetch_cached_results(backends, query, opts)

    uncached_backends
      |> Enum.map(&async_query(&1, query, opts))
      |> Task.yield_many(timeout)
      |> Enum.map(fn { task, res } -> res || Task.shutdown(task, :brutal_kill) end)
      |> Enum.flat_map(fn 
        { :ok, results } -> results
        _ -> []
      end)
      |> write_results_to_cache(query, opts)
      |> Kernel.++(cached_results)
      |> Enum.sort(&(&1.score >= &2.score))
      |> Enum.take(opts[:limit])
  end

  defp async_query(backend, query, opts) do
    Task.Supervisor.async_nolink(InfoSys.TaskSupervisor, backend, :compute, [query, opts], shutdown: :brutal_kill)
  end

  defp fetch_cached_results(backends, query, opts) do
    { uncached_backends, cached_results } = Enum.reduce(
      backends,
      { [], [] },
      fn (backend, { uncached_backends, acc_results}) ->
      case Cache.fetch({ backend.name(), query, opts[:limit] }) do
        { :ok, results } ->
          { uncached_backends, [ results | acc_results ] }
        :error ->
          { [ backend | uncached_backends ], acc_results }
      end
    end)

    { uncached_backends, List.flatten(cached_results) }
  end

  defp write_results_to_cache(results, query, opts) do
    Enum.each(results, fn (%Result{ backend: backend } = result) ->
      Task.Supervisor.async_nolink(
        InfoSys.TaskSupervisor,
        Cache,
        :put,
        [{ backend.name(), query, opts[:limit] }, result],
        shutdown: :brutal_kill)
    end)

    results
  end
end
