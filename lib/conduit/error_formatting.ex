defimpl String.Chars, for: [Conduit.ValidationError,
                            Conduit.TypeError,
                            Conduit.FieldTypeError,
                            Conduit.FieldPropertyError] do

  def to_string(%Conduit.ValidationError{}=error) do
    Conduit.ValidationError.message(error)
  end
  def to_string(%Conduit.TypeError{}=error) do
    Conduit.TypeError.message(error)
  end
  def to_string(%Conduit.FieldTypeError{}=error) do
    Conduit.FieldTypeError.message(error)
  end
  def to_string(%Conduit.FieldPropertyError{}=error) do
    Conduit.FieldPropertyError.message(error)
  end

end
