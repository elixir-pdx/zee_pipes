defmodule ZeePipe do
  def init() do
    "medical_screening_samples.csv"
      |> read_file
      |> process
      |> debug
  end

  def read_file(file) do
    file
      |> File.stream!
      |> Enum.map( &(&1) )
  end

  def process(lines) do
    lines
      |> Enum.chunk(1_000)
      |> Enum.map(&Task.async(fn -> process_lines(&1) end))
      |> Enum.flat_map(&Task.await(&1))
  end

  def debug(results) do
    results
      |> Enum.take(5)
      |> IO.inspect
  end

  def process_lines(lines) do
    lines
      |> Enum.map(&process_line(&1))
  end

  def process_line(line) do
    line
      |> String.split(",")
      |> List.to_tuple
      |> extract_fields
  end

  def extract_fields({dna, gen, _, _, _, _, _, _, _, _, _, _, wht, _, _, _, _}) do
    {dna, gen, parse_field(wht)}
  end

  def parse_field(str), do: String.slice(str, 1..-2)

end
