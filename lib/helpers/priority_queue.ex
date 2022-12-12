defmodule Helpers.PriorityQueueHelper do
  # @spec delete_value(PriorityQueue, any) :: PriorityQueue
  def delete_value(pq, value) do
    case PriorityQueue.pop(pq) do
      {{nil, nil}, _} -> pq
      {{_, v}, pq} when v == value -> pq
      {{k, v}, pq} -> pq |> delete_value(value) |> PriorityQueue.put({k, v})
    end
  end

  def upsert(pq, key, value) do
    upsert_if(pq, key, value, fn _, _ -> true end)
  end

  def upsert_if(pq, key, value, test_fn) do
    case PriorityQueue.pop(pq) do
      {{nil, nil}, _} ->
        pq |> PriorityQueue.put(key, value)

      {{k, v}, pq2} when v == value ->
        case test_fn.(key, k) do
          true -> pq2 |> PriorityQueue.put(key, value)
          false -> pq
        end

      {{k, v}, pq2} ->
        pq2 |> upsert(key, value) |> PriorityQueue.put({k, v})
    end
  end
end
