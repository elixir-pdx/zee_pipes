defmodule ZeePipeTest do
  use ExUnit.Case

  test "DNA sequence count" do
    assert ZeePipe.dna_count("TAGTAAG") == 22154
  end

  test "Get weights" do
    { min_weight, max_weight, mean_weight, female_ratio } = ZeePipe.weights()

    assert_in_delta(min_weight,     96.8, 0.1)
    assert_in_delta(mean_weight,   178.2, 0.1)
    assert_in_delta(max_weight,    257.4, 0.1)
    assert_in_delta(female_ratio,    0.5, 0.1)
  end
end
