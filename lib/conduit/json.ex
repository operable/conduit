defmodule Conduit.JSON do

  def generate(object_refs, fields) do
    quote do
      # Generate __refs__ function
      unquote(build_refs(object_refs))

      # Generate __shape__ function
      unquote(build_shape())

      # JSON encoder function
      unquote(build_encoder(fields))

      # JSON decoder function
      unquote(build_decoder())

    end
  end

  defp build_refs([]) do
    quote do
      def __refs__(), do: nil
    end
  end
  defp build_refs(fields) do
    refs = Enum.map(fields, &({Keyword.get(&1, :name),
                               module: Keyword.get(&1, :module),
                               array: Keyword.get(&1, :array)}))
    quote do
      def __refs__(), do: unquote(refs)
    end
  end


  defp build_encoder(fields) do
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

  defp build_shape() do
    quote do
      defp add_shape_field({name, props}, shape) do
        objmod = Keyword.get(props, :module)
        objshape = case Keyword.get(props, :array) || false do
                     false ->
                       objmod.__shape__()
                     true ->
                       [objmod.__shape__()]
                   end
        Map.put(shape, name, objshape)
      end

      def __shape__() do
        shape = %__MODULE__{}
        case __MODULE__.__refs__() do
          nil ->
            shape
          refs ->
            Enum.reduce(refs, shape, &add_shape_field/2)
        end
      end
    end
  end

  defp build_decoder() do
    quote do
      def decode!(data) when is_binary(data) do
        Poison.decode!(data, as: __MODULE__.__shape__())
        |> __MODULE__.validate!
      end
    end
  end

end
