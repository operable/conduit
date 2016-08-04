defmodule Conduit.Util do

  def enum_type_name(value) do
    cond do
      is_binary(value) ->
        :string
      is_integer(value) ->
        :integer
      is_float(value) ->
        :float
      is_boolean(value) ->
        :bool
      true ->
        {:invalid, value}
    end
  end

  def struct_from_map(data, struct_type) do
    case Poison.encode(data) do
      {:ok, json} ->
        struct_type.decode(json)
      error ->
        error
    end
  end

  def struct_from_map!(data, struct_type) do
    json = Poison.encode!(data)
    struct_type.decode!(json)
  end

end
