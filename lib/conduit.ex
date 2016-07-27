defmodule Conduit do

  alias Conduit.FieldTypes
  alias Conduit.FieldProperties

  defmacro __using__(_) do
    quote do
      alias Conduit.FieldTypes
      alias Conduit.FieldProperties

      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :struct_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :object_refs, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro field(name, type, props \\ [required: false, omit_empty: true])

  defmacro field(name, type, props) do
    {type, normalized_type} = type |> add_obj_prefix |> normalize_type
    FieldTypes.validate_option!(normalized_type)
    FieldProperties.validate_options!(props)
    quote do
      @fields [name: unquote(name), type: unquote(type)] ++ unquote(props)
      @struct_fields unquote(name)
      unquote(maybe_add_object_ref_field(name, normalized_type))
    end
  end

  defmacro __before_compile__(env) do
    all_fields = Module.get_attribute(env.module, :fields)
    object_refs = Module.get_attribute(env.module, :object_refs)
    quote do
      defstruct @struct_fields

      # Generate field and struct validation logic
      unquote(Conduit.Validator.generate(all_fields))

      # Generate JSON encoder/decoder logic
      unquote(Conduit.JSON.generate(object_refs, all_fields))
    end
  end

  defp maybe_add_object_ref_field(name, object: type) do
    quote do
      @object_refs [name: unquote(name), module: unquote(type), array: false]
    end
  end
  defp maybe_add_object_ref_field(name, array: [object: type]) do
    quote do
      @object_refs [name: unquote(name), module: unquote(type), array: true]
    end
  end
  defp maybe_add_object_ref_field(_, _) do
    nil
  end

  defp add_obj_prefix({:__aliases__, _, _}=type) do
    [object: type]
  end
  defp add_obj_prefix([object: type]) do
    add_obj_prefix(type)
  end
  defp add_obj_prefix([array: type]) do
    [array: add_obj_prefix(type)]
  end
  defp add_obj_prefix(type), do: type

  defp normalize_type([object: {:__aliases__, _, name}=ot]) do
    {[object: ot], [object: Module.safe_concat(name)]}
  end
  defp normalize_type([array: type]=ot) do
    {_, normalized} = normalize_type(type)
    {ot, [array: normalized]}
  end
  defp normalize_type(type), do: {type, type}
end
