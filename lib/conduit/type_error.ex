defmodule Conduit.TypeError do

  defexception [:type, :value]

  def new(type, value) do
    %__MODULE__{type: type, value: value}
  end

  def message(%__MODULE__{type: type, value: value}) do
    "Received #{inspect value} when expecting instance of #{inspect type} or its JSON equivalent."
  end

end
