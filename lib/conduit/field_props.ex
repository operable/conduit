defmodule Conduit.FieldProperties do

  alias Conduit.Util

  def validate_options!(props) when is_list(props) do
    if Keyword.keyword?(props) do
      validate_each_option!(props)
    else
      raise CompileError, description: option_error(props)
    end
  end
  def validate_options!(props) do
    raise CompileError, description: option_error(props)
  end

  def enforce(:required, nil) do
    Conduit.FieldPropertyError.new(property: :required, value: nil)
  end
  def enforce(:required, _), do: nil

  def enforce(:enum, _values, nil), do: nil
  def enforce(:enum, values, value) do
    unless value in values do
      Conduit.FieldPropertyError.new(property: [enum: values], value: value)
    end
  end

  defp validate_each_option!([]), do: :ok
  defp validate_each_option!([{:required, flag}|t]) when is_boolean(flag), do: validate_each_option!(t)
  defp validate_each_option!([{:omit_empty, flag}|t]) when is_boolean(flag), do: validate_each_option!(t)
  defp validate_each_option!([{:enum, values}|t]) when is_list(values) do
    validate_enum!(nil, values)
    validate_each_option!(t)
  end
  defp validate_each_option!([prop|_]), do: raise CompileError, description: prop_option_error(prop)

  defp validate_enum!(nil, [_]), do: :ok
  defp validate_enum!(nil, [value|t]) do
    validate_enum!(Util.enum_type_name(value), t)
  end
  defp validate_enum!({:invalid, value}, _), do: raise CompileError, description: enum_value_error(value)
  defp validate_enum!(_, []), do: :ok
  defp validate_enum!(prev_type, [value|t]) do
    case Util.enum_type_name(value) do
      {:invalid, value} ->
        raise CompileError, description: enum_value_error(value)
      ^prev_type ->
        validate_enum!(prev_type, t)
      new_type ->
        raise CompileError, description: inconsistent_enum_values_error(prev_type, new_type)
    end
  end

  defp inconsistent_enum_values_error(prev_type, new_type) do
    """
Inconsistent enum detected: '#{prev_type}', '#{new_type}'.
"""
  end

  defp enum_value_error(value) do
    """
Type detection failed for enum value '#{inspect value}'.
Allowed data types are :string, :integer, :float, :bool.
"""
  end

  defp option_error(props) do
    """
Invalid field property list: #{inspect props}.
Field properties must be formatted as a keyword list.
"""
  end
  defp prop_option_error(prop) do
    """
Invalid field property #{inspect [prop]}."
#{valid_properties_message()}
"""
  end

  defp valid_properties_message do
    """
Valid properties are:
  enum: <list_of_values>
  required: true|false
  omit_empty: true_false
"""
  end

end
