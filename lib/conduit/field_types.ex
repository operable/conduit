defmodule Conduit.FieldTypes do

  def validate_option!(:string), do: :ok
  def validate_option!(:integer), do: :ok
  def validate_option!(:float), do: :ok
  def validate_option!(:number), do: :ok
  def validate_option!(:bool), do: :ok
  def validate_option!([array: type]) do
    validate_option!(type)
  end
  def validate_option!([object: type]) do
    validate_option!(type)
  end
  def validate_option!(type) when is_atom(type) do
    :ok
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
        %Conduit.FieldTypeError{type: type, value: v, errors: error}
    end
  end
  def enforce(type, value) do
    Conduit.FieldTypeError.new(type: type, value: value)
  end

  defp type_option_error(type) do
    """
Invalid field type #{inspect type}.
Valid built-in field types: :string, :integer, :float, :number, :bool, or Elixir module name.
Valid composite field types: [array: type] or [object: type].
"""
  end

  defp enforce_composite_type(type, v, errors) do
    case enforce(type, v) do
      nil ->
        {:cont, errors}
      error ->
        {:halt, [error|errors]}
    end
  end

end