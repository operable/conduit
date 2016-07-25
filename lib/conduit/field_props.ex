defmodule Conduit.FieldProperties do
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

  defp validate_each_option!([]), do: :ok
  defp validate_each_option!([{:required, flag}|t]) when is_boolean(flag), do: validate_each_option!(t)
  defp validate_each_option!([{:omit_empty, flag}|t]) when is_boolean(flag), do: validate_each_option!(t)
  defp validate_each_option!([prop|_]), do: raise CompileError, description: prop_option_error(prop)

  defp option_error(props) do
    """
Invalid field property list: #{inspect props}.
Field properties must be formatted as a keyword list.
"""
  end
  defp prop_option_error(prop) do
    """
Invalid field property #{inspect prop}."
#{valid_properties_message}
"""
  end

  defp valid_properties_message do
    """
Valid properties are:
  required: true|false
  omit_empty: true_false
"""
  end

end
