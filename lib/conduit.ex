defmodule Conduit do

  alias Conduit.FieldTypes
  alias Conduit.FieldProperties
  alias Conduit.JSON
  alias Conduit.Util

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
    required_fields = Util.get_required_fields(env.module)
                      |> Enum.map(&(Keyword.get(&1, :name)))
    object_refs = Module.get_attribute(env.module, :object_refs)
    quote do
      defstruct @struct_fields

      def validate(%__MODULE__{}=data) do
        errors = enforce_required([], data) |> enforce_types(data)
        case errors do
          [] ->
            :ok
          errors ->
            %Conduit.ValidationError{value: data, errors: errors}
        end
      end

      def validate!(data) do
        case validate(data) do
          :ok ->
            data
          error ->
            raise error
        end
      end

      # JSON decode "shape" for object references
      unquote(JSON.build_decode_shape(object_refs))

      # Object refs
      unquote(build_refs(object_refs))

      # JSON encoder function
      unquote(JSON.build_encoder(all_fields))

      # JSON decoder function
      unquote(JSON.build_decoder())

      # Enforce required fields
      unquote(build_enforce_required(required_fields))

      # Enforce field types
      unquote(build_enforce_types(all_fields))

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

  defp build_enforce_required(fields) do
    quote do
      defp enforce_required(errors, data) do
        Enum.reduce(unquote(fields), errors,
          fn(fname, errors) ->
            case FieldProperties.enforce(:required, Map.get(data, fname)) do
              nil ->
                errors
              error ->
                [%{error | field: fname}|errors]
            end end)
      end
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


  defp build_enforce_types([]) do
    quote do
      defp enforce_types(errors, _), do: errors
    end
  end
  defp build_enforce_types(fields) do
    quote location: :keep do
      defp enforce_types(errors, data) do
        Enum.reduce(unquote(fields), errors,
          fn(fdef, errors) ->
            fname = Keyword.get(fdef, :name)
            ftype = Keyword.get(fdef, :type)
            case FieldTypes.enforce(ftype, Map.get(data, fname)) do
              nil ->
                errors
              error ->
                [%{error | field: fname}|errors]
            end end)
      end
    end
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
  defp normalize_type(type) when is_atom(type), do: {type, type}
end
