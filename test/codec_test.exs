defmodule Conduit.EncodeTest do
  use ExUnit.Case

  alias Conduit.Test.Support.Messages.User
  alias Conduit.Test.Support.Messages.Group
  alias Conduit.Test.Support.Messages.MapMessage

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

  test "Empty nested object ref is successfully nilified" do
    data = Poison.encode!(%{name: "burgermeisters", members: [%{first_name: "Wendy", last_name: "Burger",
                                                                profile: %{}}]})
    group = Group.decode!(data)
    assert group.name == "burgermeisters"
    assert length(group.members) == 1
    user = Enum.at(group.members, 0)
    assert user.__struct__ == User
    assert user.first_name == "Wendy"
    assert user.last_name == "Burger"
    refute user.profile
  end

  test "Invalid nested object ref raises ValidationError" do
    data = Poison.encode!(%{name: "burgermeisters", members: [%{first_name: "Wendy", last_name: "Burger",
                                                                profile: %{color_scheme: 123}}]})
    assert_raise Conduit.ValidationError, fn -> Group.decode!(data) end
  end

  test "Valid nested object refs survive nilification" do
    data = Poison.encode!(%{name: "burgermeisters", members: [%{first_name: "Wendy", last_name: "Burger",
                                                                profile: %{nickname: "wendinator"}},
                                                              %{first_name: "Burger", last_name: "King",
                                                                profile: %{}}]})
    group = Group.decode!(data)
    assert group.name == "burgermeisters"
    assert length(group.members) == 2
    first = Enum.at(group.members, 0)
    second = Enum.at(group.members, 1)
    assert first.first_name == "Wendy"
    assert first.last_name == "Burger"
    assert first.profile.nickname == "wendinator"
    assert second.first_name == "Burger"
    assert second.last_name == "King"
    refute second.profile
  end

  test "Objects round trip and produce identical results" do
    group = Poison.encode!(%{name: "burgermeisters", members: [%{first_name: "Wendy", last_name: "Burger",
                                                                 profile: %{nickname: "wendinator"}},
                                                               %{first_name: "Burger", last_name: "King",
                                                                 profile: %{}}]}) |> Group.decode!
    data = Group.encode!(group)
    assert Group.decode!(data) === group
  end

  test "Poison options are supported" do
    group = Poison.encode!(%{name: "burgermeisters", members: [%{first_name: "Wendy", last_name: "Burger",
                                                                 profile: %{nickname: "wendinator"}},
                                                               %{first_name: "Burger", last_name: "King",
                                                                 profile: %{}}]}) |> Group.decode!
    data = Group.encode!(group, pretty: true)
    assert String.contains?(data, "\n")
  end

  test "Empty JSON map raises ValidationError" do
    assert_raise Conduit.ValidationError, fn -> Group.decode!("{}") end
  end

  test "Empty map fields are decoded" do
    data = Poison.encode!(%{v: %{}, va: [%{}]})
    m = MapMessage.decode!(data)
    assert m.v == %{}
    assert m.va == [%{}]
    assert MapMessage.encode!(m) == data
  end

  test "Conduit struct is created from valid map" do
    data = %{first_name: "Wendy", last_name: "Burger", profile: %{nickname: "wendinator"}}
    {:ok, user} = User.from_map(data)
    assert user.first_name == "Wendy"
    assert user.last_name == "Burger"
    assert user.profile.nickname == "wendinator"
  end

  test "Conduit struct creation fails with invalid map" do
    data = %{first_name: "Wendy"}
    assert_raise Conduit.ValidationError, fn -> User.from_map!(data) end
  end

  test "Conduit struct creation fails with empty map" do
    data = %{}
    assert_raise Conduit.ValidationError, fn -> User.from_map!(data) end
  end

end
