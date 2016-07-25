defmodule Conduit.ValidateValuesTest do

  use Conduit.Test.Support.CaseGenerator

  doctest Conduit

  # Integer values
  value_test "Validating integers works", Messages.IntMessage, ["foo", 1, [1, "foo"], [1,2]]

  # Float values
  value_test "Validating floats works", Messages.FloatMessage, [true, 1.5, [1, 0.1], [1.5, 2.3]]

  # Numeric values
  value_test "Validating floats as numbers works", Messages.NumberMessage, ["abc", 1.5, [1.0, false], [1.0, 2.3]]
  value_test "Validating integers as numbers works", Messages.NumberMessage, ["abc", 1, [true, 1], [1,2,3]]

  # Bool values
  value_test "Validating booleans works", Messages.BoolMessage, [1, false, [false, "true"], [true, true]]

  # String values
  value_test "Validating strings works", Messages.StringMessage, [nil, "abc", [1, 0], ["abc", "def"]]

end
