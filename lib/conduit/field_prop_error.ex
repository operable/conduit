defmodule Conduit.FieldPropertyError do
  defexception [:field, :property, :value]

  def exception(props) do
    new(props)
  end

  def message(%__MODULE__{field: fname, property: property, value: value}) do
    case property do
      :required ->
        "Value for required field '#{fname}' is missing."
      [enum: values] ->
        "Value for field #{fname} is '#{value}'. Allowed values are #{inspect values}."
      _ ->
        "Unknown property error for field '#{fname}' Value is #{inspect value}."
    end
  end

  def new(props) do
    fname = Keyword.get(props, :field)
    property = Keyword.get(props, :property)
    value = Keyword.get(props, :value)
    %__MODULE__{field: fname, property: property, value: value}
  end

end
