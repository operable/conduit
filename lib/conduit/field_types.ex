defmodule Conduit.FieldTypes do

  def validate_option!(:string), do: :ok
  def validate_option!(:integer), do: :ok
  def validate_option!(:float), do: :ok
  def validate_option!(:number), do: :ok
  def validate_option!(:bool), do: :ok
  def validate_option!(:map), do: :ok
  def validate_option!(:array), do: :ok
  def validate_option!([array: type]) when type != :array do
    validate_option!(type)
  end
  def validate_option!([object: type]) do
    validate_option!(type)
  end
  def validate_option!(:map_or_array_of_maps), do: :ok
  def validate_option!(type) when is_atom(type) do
    name = Atom.to_string(type)
    # Regex is proxy for valid module name
    case Regex.match?(~r/^[A-Z].*/, name) do
      true ->
        :ok
      false ->
        raise CompileError, description: type_option_error(type)
    end
  end
  def validate_option!(type) do
    raise CompileError, description: type_option_error(type)
  end

  def enforce(_, nil), do: nil
  def enforce(:string, v) when is_binary(v), do: nil
  def enforce(:integer, v) when is_integer(v), do: nil
  def enforce(:float, v) when is_float(v), do: nil
  def enforce(:number, v) when is_integer(v) or is_float(v), do: nil
  def enforce(:bool, v) when is_boolean(v), do: nil
  def enforce(:array, v) when is_list(v), do: nil
  def enforce(:map, v) when is_map(v), do: nil

  def enforce(:map_or_array_of_maps, v) when is_map(v), do: nil
  def enforce(:map_or_array_of_maps, v) when is_list(v) do
    if Enum.all?(v, &is_map/1) do
      nil
    else
      Conduit.FieldTypeError.new(type: :map_or_array_of_maps, value: v)
    end
  end
  def enforce([array: type], values) when is_list(values) do
    case Enum.reduce_while(values, [], &(enforce_composite_type(type, &1, &2))) do
      [] ->
        nil
      [%Conduit.FieldTypeError{type: type}=error] ->
        %{error | type: [array: type]}
    end
  end
  def enforce([object: type], v) when is_map(v) do
    case type.validate(v) do
      :ok ->
        nil
      error ->
        Conduit.FieldTypeError.new(type: type, value: v, errors: error)
    end
  end
  def enforce(type, value) do
    Conduit.FieldTypeError.new(type: type, value: value)
  end

  defp enforce_composite_type(type, v, errors) do
    case enforce(type, v) do
      nil ->
        {:cont, errors}
      error ->
        {:halt, [error|errors]}
    end
  end

  defp type_option_error(type) do
    """
Invalid field type #{inspect type}.
Valid built-in field types: :string, :integer, :float, :number, or :bool.
Valid untyped aggregate field types: :array or :map.
Valid aggregate field types: [object: type] or [array: type] where type is a built-in or Elixir module name.

"""
  end


end
