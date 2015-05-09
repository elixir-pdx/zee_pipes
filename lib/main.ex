defmodule ZeePipe do
  def init() do
    Collector.start_link

    "medical_screening_samples.csv"
      |> File.stream!
      |> Enum.map( &(&1) )
      |> process

    Collector.output
  end

  def process(lines) do
    lines
      |> Enum.chunk(10_000)
      |> Enum.map(&Task.async(fn -> process_lines(&1) end))
      |> Enum.map(&Task.await(&1))
  end

  def process_lines(lines) do
    lines
      |> Enum.map(&process_line(&1))
      |> Collector.update
  end

  def process_line(line) do
    line
      |> String.split(",")
      |> List.to_tuple
      |> extract_fields
  end

  def extract_fields({dna, gen, _, _, _, _, _, _, _, _, _, _, wht, _, _, _, _}) do
    { extract_fields(:dna, dna), extract_fields(:gen, gen), extract_fields(:wht, wht) }
  end

  def extract_fields(:dna, dna), do: String.match?(dna, ~r/TAGTAAG/)
  def extract_fields(:gen, gen), do: String.match?(gen, ~r/female/)
  def extract_fields(:wht, wht), do: ({num, _} = wht |> String.slice(1..-2) |> Float.parse; num)

end

defmodule Collector do
  def start_link(), do: Agent.start_link(fn -> {0, 0, 100, 0, 0, 0} end, name: __MODULE__)

  def update(results) do
    Agent.update(__MODULE__, fn state ->
      Enum.reduce(results, state, fn x, acc ->
        {next_dna, next_gen, next_min, next_max, next_sum, next_n} = acc
        {this_dna, this_gen, this_wht} = x

        next_dna = next_dna + (this_dna && 1 || 0)
        next_gen = next_gen + (this_gen && 1 || 0)
        next_min = this_wht < next_min && this_wht || next_min
        next_max = this_wht > next_max && this_wht || next_max
        next_sum = next_sum + this_wht
        next_n   = next_n + 1

        {next_dna, next_gen, next_min, next_max, next_sum, next_n}
      end)
    end)
  end

  def output() do
    {dna, gen, min, max, sum, n} = Agent.get(__MODULE__, &(&1))

    IO.inspect %{ zombies: Float.round(100*dna/n, 1), women: Float.round(100*gen/n, 1), mean: Float.round(sum/n, 2), min: min, max: max }
  end
end
