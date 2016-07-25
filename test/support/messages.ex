defmodule Conduit.Test.Support.Messages.IntMessage do

  use Conduit

  field :v, :integer, required: true
  field :va, [array: :integer], required: true

end

defmodule Conduit.Test.Support.Messages.FloatMessage do

  use Conduit

  field :v, :float, required: true
  field :va, [array: :float], required: true

end

defmodule Conduit.Test.Support.Messages.BoolMessage do

  use Conduit

  field :v, :bool, required: true
  field :va, [array: :bool], required: true

end

defmodule Conduit.Test.Support.Messages.StringMessage do

  use Conduit

  field :v, :string, required: true
  field :va, [array: :string], required: true

end

defmodule Conduit.Test.Support.Messages.NumberMessage do

  use Conduit

  field :v, :number, required: true
  field :va, [array: :number], required: true

end

defmodule Conduit.Test.Support.Messages.User do

  use Conduit

  field :first_name, :string, required: true
  field :last_name, :string, required: true
  field :email, :string, omit_empty: true
  field :profile, [object: Conduit.Test.Support.Messages.UserProfile]
end

defmodule Conduit.Test.Support.Messages.UserProfile do

  use Conduit

  field :color_scheme, :string
  field :nickname, :string, required: true

end


defmodule Conduit.Test.Support.Messages.Group do

  use Conduit

  field :name, :string, required: true
  field :members, [array: Conduit.Test.Support.Messages.User], required: false, omit_empty: true

end
