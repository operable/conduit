defimpl String.Chars, for: Conduit.ValidationError do

  def to_string(error) do
    Conduit.ValidationError.message(error)
  end

end

defimpl String.Chars, for: Conduit.FieldTypeError do

  def to_string(error) do
    Conduit.FieldTypeError.message(error)
  end

end

defimpl String.Chars, for: Conduit.FieldPropertyError do

  def to_string(error) do
    Conduit.FieldPropertyError.message(error)
  end

end
