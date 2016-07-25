defmodule Conduit.EncodeTest do
  use ExUnit.Case

  alias Conduit.Test.Support.Messages.User

  test "Missing required field raises ValidationError" do
    data = Poison.encode!(%{first_name: "Wendy"})
    assert_raise Conduit.ValidationError, fn -> User.decode!(data) end
  end

  test "Valid JSON can be decoded" do
    data = Poison.encode!(%{first_name: "Wendy", last_name: "Burger"})
    user = User.decode!(data)
    assert user.first_name == "Wendy"
    assert user.last_name == "Burger"
  end

  test "Invalid object ref raises ValidationError" do
    data = Poison.encode!(%{first_name: "Wendy", last_name: "Burger", profile: %{color_scheme: 123}})
    assert_raise Conduit.ValidationError, fn -> User.decode!(data) end
  end
end
