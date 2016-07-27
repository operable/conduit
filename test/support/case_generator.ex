defmodule Conduit.Test.Support.CaseGenerator do

  defmacro __using__(_) do
    quote do
      use ExUnit.Case

      import unquote(__MODULE__), only: [value_test: 3]
      alias Conduit.Test.Support.Messages

    end
  end

  defmacro value_test(desc, module, [v_no, v_yes, ve_no, ve_yes, va_no, va_yes]) do
    quote location: :keep do
      test "#{unquote(desc)}" do
        m = %unquote(module){}
        # all fields are blank
        assert_raise Conduit.ValidationError, fn -> unquote(module).validate!(m) end

        m = %{m | v: unquote(v_no)}
        # v is wrong type; va is still blank
        assert_raise Conduit.ValidationError, fn -> unquote(module).validate!(m) end

        m = %{m | v: unquote(v_yes)}
        # va is still blank
        assert_raise Conduit.ValidationError, fn -> unquote(module).validate!(m) end

        m = %{m | ve: unquote(ve_no)}
        # ve is wrong type; va is still blank
        assert_raise Conduit.ValidationError, fn -> unquote(module).validate!(m) end

        m = %{m | ve: unquote(ve_yes)}
        # va is still blank
        assert_raise Conduit.ValidationError, fn -> unquote(module).validate!(m) end

        m = %{m | va: unquote(va_no)}
        # va is wrong type
        assert_raise Conduit.ValidationError, fn -> unquote(module).validate!(m) end

        # both fields are correct
        m = %{m | va: unquote(va_yes)}
        unquote(module).validate!(m)

      end
    end
  end

end
