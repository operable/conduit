# Conduit

[![Build Status](https://travis-ci.org/operable/conduit.svg?branch=master)](https://travis-ci.org/operable/conduit)
[![Coverage Status](https://coveralls.io/repos/github/operable/conduit/badge.svg?branch=master)](https://coveralls.io/github/operable/conduit?branch=master)

Typed and validated JSON encoder and decoder

## Installation

```elixir
def deps do
  [{:conduit, github: "operable/conduit", branch: "master"}]
end
```

## Usage

### Defining Conduit structs

```elixir
defmodule MyApp.User do
  use Conduit

  field :first_name, :string, required: true
  field :last_name, :string, required: true
  field :userid, :string, required: true
end

defmodule MyApp.Request do
  use Conduit

  field :command, :string, required: true
  field :args, array: :string
  field :requestor, object: MyApp.User
end
```

### Marshaling and unmarshaling

```elixir
try do
  request = MyApp.Request.decode!(json)
rescue
  e in Conduit.ValidationError ->
    log_bad_data(e, json)
end
```

### Validation

```elixir
request = MyApp.Request.decode!(json) |> evaluate_args
try do
  request.validate!
rescue
  e in Conduit.ValidatinError ->
    log_bad_args(e, json)
end
```
