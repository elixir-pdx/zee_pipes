defmodule ZeePipe do
  def init do
    :ok
  end

  def get_dna_gender_weight([ dna, gender, _name, _address, _city, _state, _zip, _phone, _birth, _ssn,
                              _employment, _blood_type, weight, _height, _lat, _long, _symptomatic ]) do
    { dna, gender, elem(Float.parse(String.slice(weight, 1, String.length(weight)-2)), 0) }
  end

  def merge_result({ a_dna_count, a_min_weight, a_max_weight, a_total_weight, a_total_count, a_female_count },
                   { b_dna_count, b_min_weight, b_max_weight, b_total_weight, b_total_count, b_female_count }) do
    { a_dna_count + b_dna_count,
      min(a_min_weight, b_min_weight),
      max(a_max_weight, b_max_weight),
      a_total_weight + b_total_weight,
      a_total_count + b_total_count,
      a_female_count + b_female_count }
  end

  def decode_csv(line) do
    String.split(line, ",")
  end

  def worker(state = { dna_count, min_weight, max_weight, total_weight, total_count, female_count }, sequence) do
    receive do
      { :line  , line   } ->

        { dna, gender, weight } = get_dna_gender_weight(decode_csv(line))

        dna_match    = if String.contains?(dna, sequence)    do 1 else 0 end
        female_match = if String.contains?(gender, "female") do 1 else 0 end

        worker(merge_result(state, { dna_match, weight, weight, weight, 1, female_match }), sequence)

      { :finish, sender } -> send sender, { :get_result, { dna_count, min_weight, max_weight, total_weight, total_count, female_count } }
    end
  end

  def assign_line_to_worker(line, { workers, index }) do
    worker = Enum.at(workers, index)
    send worker, { :line, line }

    { workers, rem(index + 1, Enum.count(workers)) }
  end

  def accumulate_result({ workers, _ }) do
    Enum.map(workers, fn(worker) -> send worker, { :finish, self() } end)

    Enum.map(workers, fn(_) -> receive do { :get_result, result } -> result end end)
    |> Enum.reduce(&merge_result/2)
  end

  def get_results(sequence) do
    workers = Enum.map(1..10, fn(_) -> spawn_link(ZeePipe, :worker, [ {0, 99999, 0, 0, 0, 0 }, sequence ]) end)
    File.stream!(Path.expand("~/Desktop/medical_screening_samples.csv"))
    #|> Enum.take(5)
    |> Enum.reduce({ workers, 0 }, &(assign_line_to_worker(&1,&2)))
    |> accumulate_result()
  end

  def dna_count(sequence) do
    { dna_count, _min_weight, _max_weight, _total_weight, _total_count, _female_count } = get_results(sequence)

    dna_count
  end

  def weights() do
    { _dna_count, min_weight, max_weight, total_weight, total_count, female_count } = get_results("")

    { min_weight, max_weight, total_weight / total_count, female_count / total_count }
  end

end
