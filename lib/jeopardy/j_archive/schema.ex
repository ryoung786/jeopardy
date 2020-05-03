defmodule Jeopardy.JArchive.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @schema_prefix "jarchive"
    end
  end
end
