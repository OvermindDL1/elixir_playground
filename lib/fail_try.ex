defmodule MyFail do

  alias A.B

  def method do
    B.nonexistent
  end

end
