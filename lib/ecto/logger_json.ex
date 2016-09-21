defmodule Ecto.LoggerJSON do
  @moduledoc """
  Keep in sync with https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/log_entry.ex

  Struct used for logging entries.
  It is composed of the following fields:
    * query - the query as string or a function that when invoked resolves to string;
    * source - the query data source;
    * params - the query parameters;
    * result - the query result as an `:ok` or `:error` tuple;
    * query_time - the time spent executing the query in native units;
    * decode_time - the time spent decoding the result in native units (it may be nil);
    * queue_time - the time spent to check the connection out in native units (it may be nil);
    * connection_pid - the connection process that executed the query;
    * ansi_color - the color that chould be used when logging the entry.
  Notice all times are stored in native unit. You must convert them to
  the proper unit by using `System.convert_time_unit/3` before logging.
  """

  alias Ecto.LogEntry

  @type t :: %LogEntry{query: String.t | (t -> String.t), source: String.t | Enum.t | nil,
                       params: [term], query_time: integer, decode_time: integer | nil,
                       queue_time: integer | nil, connection_pid: pid | nil,
                       result: {:ok, term} | {:error, Exception.t},
                       ansi_color: IO.ANSI.ansicode | nil}

  defstruct query: nil, source: nil, params: [], query_time: nil, decode_time: nil,
            queue_time: nil, result: nil, connection_pid: nil, ansi_color: nil

  require Logger

  @doc """
  Overwritten to use JSON
  Logs the given entry in debug mode.
  The logger call will be removed at compile time if
  `compile_time_purge_level` is set to higher than debug.
  """
  def log(entry) do
    Logger.debug(fn ->
      %{query_time: query_time, decode_time: decode_time, queue_time: queue_time, query: query} = entry
      [query_time, decode_time, queue_time] =
        [query_time, decode_time, queue_time]
        |> Enum.map(&format_time/1)

      %{
        "decode_time" => decode_time,
        "duration"    => Float.round(query_time + decode_time + queue_time, 3),
        "log_type"    => "persistence",
        "request_id"  => Logger.metadata[:request_id],
        "query"       => query,
        "query_time"  => query_time,
        "queue_time"  => queue_time
      }
      |> Poison.encode!
    end)
    entry
  end

  @doc """
  Overwritten to use JSON
  Logs the given entry in the given level.
  The logger call won't be removed at compile time as
  custom level is given.
  """
  def log(entry, level) do
    Logger.log(level, fn ->
      %{query_time: query_time, decode_time: decode_time, queue_time: queue_time, query: query} = entry
      [query_time, decode_time, queue_time] =
        [query_time, decode_time, queue_time]
        |> Enum.map(&(Float.round(System.convert_time_unit(&1, :native, :micro_seconds) / 1000, 3)))

      %{
        "decode_time" => decode_time,
        "duration"    => Float.round(query_time + decode_time + queue_time, 3),
        "log_type"    => "persistance",
        "request_id"  => Logger.metadata[:request_id],
        "query"       => query,
        "query_time"  => query_time,
        "queue_time"  => queue_time
      }
      |> Poison.encode!
    end)
    entry
  end

  ## Helpers

  defp format_time(nil), do: -1
  defp format_time(time) do
    ms = System.convert_time_unit(time, :native, :micro_seconds) / 1000
    Float.round(ms, 3)
  end
end
