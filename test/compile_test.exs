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

  test "Inconsistent enums are detected" do
    quoted = quote do
      defmodule Foo2 do
        use Conduit

        field :name, :string, enum: ["a", 1,"c"]

      end
    end

    assert_raise CompileError, fn -> Code.compile_quoted(quoted) end
  end

  test "Invalid enum data types are detected" do
    quoted = quote do
      defmodule Foo3 do
        use Conduit

        field :name, :string, enum: [%{"a" => 1}]
      end
    end

    assert_raise CompileError, fn -> Code.compile_quoted(quoted) end
  end

  test "Nested untyped arrays are not allowed" do
    quoted = quote do
      defmodule Foo4 do
        use Conduit

        field :name, [array: :array]
      end
    end

    assert_raise CompileError, fn -> Code.compile_quoted(quoted) end
  end

end
