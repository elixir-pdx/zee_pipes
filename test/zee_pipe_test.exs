defmodule ZeePipeTest do
  use ExUnit.Case

  test "DNA sequence count" do
    assert ZeePipe.dna_count("TAGTAAG") == 22154
  end
end
