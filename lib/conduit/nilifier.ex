defmodule Conduit.Nilifier do

  def nilify(obj) when is_map(obj) do
    if empty_ref?(obj) do
      nil
    else
      objmod = obj.__struct__
      case objmod.__refs__() do
        nil ->
          obj
        refs ->
          obj = Enum.reduce(refs, obj, &nilify_field/2)
          if empty_ref?(obj) do
            nil
          else
            obj
          end
      end
    end
  end
  def nilify(obj) when is_list(obj) do
    if empty_ref?(obj) do
      nil
    else
      case Enum.map(obj, &nilify/1) |> Enum.filter(&(&1 != nil)) do
        [] ->
          nil
        obj ->
          obj
      end
    end
  end
  def nilify(obj), do: obj

  defp nilify_field({name, props}, obj) do
    objmod = Keyword.get(props, :module)
    value = Map.get(obj, name)
    Map.put(obj, name, nilify(value))
  end

  defp empty_ref?(obj) when is_map(obj) do
    (obj |> Map.from_struct |> Map.values |> Enum.uniq) == [nil]
  end
  defp empty_ref?(obj) when is_list(obj) do
    Enum.uniq(obj) == [nil]
  end

end
