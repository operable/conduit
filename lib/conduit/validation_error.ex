defmodule Conduit.ValidationError do
  defexception [:value, :errors, :message]

  def exception(props) do
    new(props)
  end

  def message(%__MODULE__{errors: errors}) do
    Enum.join(Enum.map(errors, &("#{&1}")), "\n")
  end

  def new(props) do
    value = Keyword.get(props, :value)
    errors = Keyword.get(props, :errors)
    %__MODULE__{value: value, errors: errors}
  end

end
