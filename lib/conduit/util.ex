defmodule Conduit.Util do

  def get_required_fields(module) do
    Module.get_attribute(module, :fields)
    |> Enum.filter(&(Keyword.get(&1, :required)))
  end

end
