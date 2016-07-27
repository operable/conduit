defmodule Conduit.CompileTest do

  use ExUnit.Case

  test "Invalid field type raises" do
    quoted = quote do
      defmodule Foo do
        use Conduit

        field :name, :binary

      end
    end
    assert_raise CompileError, fn -> Code.compile_quoted(quoted) end
  end

  test "Invalid field option raises" do
    quoted = quote do
      defmodule Foo do
        use Conduit

        field :name, :number, cast: true
      end
    end

    assert_raise CompileError, fn -> Code.compile_quoted(quoted) end
  end

end
