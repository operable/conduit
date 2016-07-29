defmodule Conduit.ValidateValuesTest do

  use Conduit.Test.Support.CaseGenerator

  doctest Conduit

  # Integer values
  value_test "Validating integers works", Messages.IntMessage, ["foo", 1, 4, 1, [1, "foo"], [1,2]]

  # Float values
  value_test "Validating floats works", Messages.FloatMessage, [true, 1.5, 0.9, 0.1, [1, 0.1], [1.5, 2.3]]

  # Numeric values
  value_test "Validating floats as numbers works", Messages.NumberMessage, ["abc", 1.5, 0.1, 1, [1.0, false], [1.0, 2.3]]
  value_test "Validating integers as numbers works", Messages.NumberMessage, ["abc", 1, 0.1, 1, [true, 1], [1,2,3]]

  # Bool values
  value_test "Validating booleans works", Messages.BoolMessage, [1, false, "false", true, [false, "true"], [true, true]]

  # String values
  value_test "Validating strings works", Messages.StringMessage, [nil, "abc", "123", "a", [1, 0], ["abc", "def"]]

  test "Validating maps works" do
    m = %Messages.MapMessage{}

    # v is empty
    assert_raise Conduit.ValidationError, fn -> Messages.MapMessage.validate!(m) end

    # v is wrong type
    m = %{m | v: 123}
    assert_raise Conduit.ValidationError, fn -> Messages.MapMessage.validate!(m) end

    # v is correct
    m = %{m | v: %{}}
    Messages.MapMessage.validate!(m)

    # va is wrong type
    m = %{m | va: ["a", "b"]}
    assert_raise Conduit.ValidationError, fn -> Messages.MapMessage.validate!(m) end

    # va is still wrong type
    m = %{m | va: %{}}
    assert_raise Conduit.ValidationError, fn -> Messages.MapMessage.validate!(m) end

    # va is correct type
    m = %{m | va: [%{}]}
    Messages.MapMessage.validate!(m)
  end

  test "Map field contents are untyped" do
    m = %Messages.MapMessage{v: %{"abc" => 123, abc: true}}
    Messages.MapMessage.validate!(m)
    m = %{m | v: %{0.123 => %{}}}
    Messages.MapMessage.validate!(m)
  end

  test "Validating untyped arrays works" do
    m = %Messages.ArrayMessage{}

    # v is empty
    assert_raise Conduit.ValidationError, fn -> Messages.ArrayMessage.validate!(m) end

    # v is wrong type
    m = %{m | v: true}
    assert_raise Conduit.ValidationError, fn -> Messages.ArrayMessage.validate!(m) end

    # v is right type
    m = %{m | v: [1,2,3,"red","green","blue",true]}
    Messages.ArrayMessage.validate!(m)
    m = %{m | v: []}
    Messages.ArrayMessage.validate!(m)

    # va is wrong type
    m = %{m | va: %{}}
    assert_raise Conduit.ValidationError, fn -> Messages.ArrayMessage.validate!(m) end

    # va is correct type
    m = %{m | va: [%{}, "abc", 0.1]}
    Messages.ArrayMessage.validate!(m)
  end

  test "Validation works with nil non-required fields" do
    m = %Messages.IntMessageRelaxed{}
    # Non-required fields should validate when nil
    Messages.IntMessageRelaxed.validate!(m)

    # Wrong type
    m = %{m | v: "123"}
    assert_raise Conduit.ValidationError, fn -> Messages.IntMessageRelaxed.validate!(m) end

    # Correct type
    m = %{m | v: 123}
    Messages.IntMessageRelaxed.validate!(m)

    # Wrong type
    m = %{m | va: "123"}
    assert_raise Conduit.ValidationError, fn -> Messages.IntMessageRelaxed.validate!(m) end

    # Wrong types in array
    m = %{m | va: [true, "123"]}
    assert_raise Conduit.ValidationError, fn -> Messages.IntMessageRelaxed.validate!(m) end

    # Correct types in array
    m = %{m | va: [1,2]}
    Messages.IntMessageRelaxed.validate!(m)

  end

end
