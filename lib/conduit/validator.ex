defmodule Conduit.Validator do

  def generate(fields) do
    quote do
      def validate(%__MODULE__{}=data) do
        errors = enforce_required([], data) |> enforce_types(data) |> enforce_enums(data)
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

      ## These functions are used by validate/1 and validate!/1
      unquote(build_enforce_required(fields))
      unquote(build_enforce_types(fields))
      unquote(build_enforce_enums(fields))

    end
  end

  defp build_enforce_types(fields) do
    quote location: :keep do
      defp enforce_types(errors, data) do
        Enum.reduce(unquote(fields), errors,
          fn(fdef, errors) ->
            fname = Keyword.get(fdef, :name)
            ftype = Keyword.get(fdef, :type)
            case Conduit.FieldTypes.enforce(ftype, Map.get(data, fname)) do
              nil ->
                errors
              error ->
                [%{error | field: fname}|errors]
            end end)
      end
    end
  end

  defp build_enforce_required(fields) do
    case Enum.filter(fields, &Keyword.get(&1, :required)) |> Enum.map(&Keyword.get(&1, :name)) do
      [] ->
        quote do
          defp enforce_required(errors, _data) do
            errors
          end
        end
      reqd ->
        quote do
          defp enforce_required(errors, data) do
            Enum.reduce(unquote(reqd), errors,
              fn(fname, errors) ->
                case Conduit.FieldProperties.enforce(:required, Map.get(data, fname)) do
                  nil ->
                    errors
                  error ->
                    [%{error | field: fname}|errors]
                end end)
          end
      end
    end
  end


  defp build_enforce_enums(fields) do
    case Enum.filter(fields, &Keyword.get(&1, :enum)) do
      [] ->
        quote do
          defp enforce_enums(errors, _data), do: errors
        end
      enums ->
        quote do
          defp enforce_enums(errors, data) do
            Enum.reduce(unquote(enums), errors,
              fn(enum, errors) ->
                fname = Keyword.get(enum, :name)
                case Conduit.FieldProperties.enforce(:enum, Keyword.get(enum, :enum), Map.get(data, fname)) do
                  nil ->
                    errors
                  error ->
                    [%{error | field: fname}|errors]
                end end)
          end
      end
    end
  end

end
