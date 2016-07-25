defmodule Conduit.ValidateCompositesTest do

  use ExUnit.Case

  alias Conduit.Test.Support.Messages.User
  alias Conduit.Test.Support.Messages.UserProfile
  alias Conduit.Test.Support.Messages.Group

  test "Validate object references" do
    user = %User{first_name: "Wendy"}
    assert_raise Conduit.ValidationError, fn -> User.validate!(user) end
    user = %{user | last_name: "Burger"}
    User.validate!(user)
    assert_raise Conduit.ValidationError, fn -> User.validate!(%{user | profile: "burgermeister"}) end
    user = %{user | profile: %UserProfile{nickname: "burgermeister"}}
    User.validate!(user)
  end

  test "Validate array of object references" do
    wendy = %User{first_name: "Wendy", last_name: "Burger"}
    User.validate!(wendy)
    king = %User{first_name: "Burger", last_name: "King"}
    User.validate!(king)
    group = %Group{name: "users", members: [king, wendy]}
    Group.validate!(group)
    assert_raise Conduit.ValidationError, fn -> Group.validate!(%{group | members: ["bob"|group.members]}) end
  end

end
