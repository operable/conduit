defmodule Conduit.JSON do

  def build_encoder(fields) do
    omit_empty_fields = Enum.filter(fields, &(Keyword.get(&1, :omit_empty, false)))
                        |> Enum.map(&(Keyword.get(&1, :name)))
    quote do
      def encode!(%__MODULE__{}=data) do
        data = __MODULE__.validate!(data)
        data = Enum.reduce(unquote(omit_empty_fields), data,
          fn(field, data) ->
            case Map.get(data, field) do
              nil ->
                Map.delete(data, field)
              _ ->
                data
            end
          end)
        Poison.encode!(data)
      end
    end
  end

  def build_decode_shape([]) do
    quote do
      def __shape__() do
        %__MODULE__{}
      end
    end
  end
  def build_decode_shape(fields) do
    quote do
      def __shape__() do
        %__MODULE__{}
        |> unquote(__MODULE__).add_refs_shape(unquote(fields))
      end
    end
  end

  def build_decoder() do
    quote do
      def decode!(data) when is_binary(data) do
        Poison.decode!(data, as: __MODULE__.__shape__())
        |> __MODULE__.validate!
      end
    end
  end

  def add_refs_shape(target, []), do: target
  def add_refs_shape(target, [field|fields]) do
    field_name = Keyword.get(field, :name)
    objmod = Keyword.get(field, :module)
    target = case Keyword.get(field, :array) do
               true ->
                 Map.put(target, field_name, [objmod.__shape__()])
               false ->
                 Map.put(target, field_name, objmod.__shape__())
             end
    add_refs_shape(target, fields)
  end

end
