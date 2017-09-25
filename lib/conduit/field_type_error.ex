defmodule Conduit.FieldTypeError do

  alias Conduit.ValidationError

  defexception [:field, :type, :value, :errors]

  def exception(props) do
    new(props)
  end

  def message(%__MODULE__{field: fname, type: type, value: value, errors: errors}) do
    make_message(fname, type, value, errors)
  end

  def new(props) do
    fname = Keyword.get(props, :field)
    type = Keyword.get(props, :type)
    value = Keyword.get(props, :value)
    errors = Keyword.get(props, :errors)
    %__MODULE__{field: fname, type: type, value: value, errors: errors}
  end


  defp make_message(fname, type, value, nil) do
    "Field '#{fname}' is of type #{inspect type}. Current value contains #{type_name(value)}."
  end
  defp make_message(fname, type, _value, error=%ValidationError{}) do
    "Field name '#{fname}' of type #{inspect type} failed validation:\n#{error}"
  end
  defp make_message(fname, type, _value, {:error, error=%ValidationError{}}) do
    "Field name '#{fname}' of type #{inspect type} failed validation:\n#{error}"
  end
  defp make_message(fname, _type, _value, errors) when is_list(errors) do
    texts = Enum.map(errors, &("  #{&1}"))
    "Field '#{fname}' failed validation:\n#{Enum.join(texts, "\n")}"
  end

  defp type_name(value) when is_binary(value), do: "string"
  defp type_name(value) when is_integer(value), do: "integer"
  defp type_name(value) when is_float(value), do: "float"
  defp type_name(value) when is_boolean(value), do: "boolean"
  defp type_name([]), do: "empty array"
  defp type_name([v|_]), do: "array of #{type_name(v)}"
  defp type_name(v) when is_map(v), do: "object"

end
