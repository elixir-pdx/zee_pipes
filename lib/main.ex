defmodule ZeePipe do
  def init do
    :ok
  end

  def worker(count) do
    receive do
      { :line  , line   } -> if String.contains?(line, "TAGTAAG") do
                                 worker(count+1)
                             else
                                 worker(count)
                             end

      { :finish, sender } -> send sender, { :count, count }
    end
  end

  def assign_line_to_worker(line, { workers, index }) do
    worker = Enum.at(workers, index)
    send worker, { :line, line }

    { workers, rem(index + 1, Enum.count(workers)) }
  end

  def accumulate_result({ workers, _ }) do
    Enum.map(workers, fn(worker) -> send worker, { :finish, self() } end)

    Enum.map(workers, fn(_) -> receive do { :count, count } -> count end end)
    |> Enum.sum()

  end

  def dna_count(sequence) do
    workers = Enum.map(1..2, fn(_) -> spawn_link(ZeePipe, :worker, [ 0 ]) end)
    File.stream!(Path.expand("~/Desktop/medical_screening_samples.csv"))
    |> Enum.reduce({ workers, 0 }, &(assign_line_to_worker(&1,&2)))
    |> accumulate_result()
  end
end
