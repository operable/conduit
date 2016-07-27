defmodule Conduit.Util do

  def get_required_fields(module) do
    Module.get_attribute(module, :fields)
    |> Enum.filter(&(Keyword.get(&1, :required)))
  end

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

end
