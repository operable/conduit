defmodule Conduit.Maps do

  def generate() do
    quote do
      def from_map(data) when is_map(data) do
        Conduit.Util.struct_from_map(data, __MODULE__)
      end

      def from_map!(data) when is_map(data) do
        Conduit.Util.struct_from_map!(data, __MODULE__)
      end
    end
  end

end
