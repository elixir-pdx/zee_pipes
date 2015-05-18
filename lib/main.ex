defmodule ZeePipe do
  def init(file) do
    Collector.start_link

    file
      |> File.stream!
      |> Stream.chunk(10_000)
      |> Enum.map(&Task.async(fn -> process(&1) end))
      |> Enum.map(&Task.await(&1))

    Collector.output
  end

  def process(lines) do
    lines
      |> Enum.map(&parse(&1))
      |> Collector.update
  end

  def parse(line) do
    [dna, gen, _, _, _, _, _, _, _, _, _, _, wht, _, _, _, _] = String.split(line, ",")
    { parse(:dna, dna), parse(:gen, gen), parse(:wht, wht) }
  end

  def parse(:dna, dna), do: dna |> String.match?(~r/TAGTAAG/)
  def parse(:gen, gen), do: gen |> String.match?(~r/female/)
  def parse(:wht, wht), do: ({num, _} = wht |> String.slice(1..-2) |> Float.parse; num)
end

defmodule Collector do
  def start_link(), do: Agent.start_link(fn -> {0, 0, 100, 0, 0, 0} end, name: __MODULE__)

  def update(results) do
    Agent.update(__MODULE__, fn state ->
      Enum.reduce(results, state, fn {this_dna, this_gen, this_wht}, acc ->
        {next_dna, next_gen, next_min, next_max, next_sum, next_n} = acc

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
