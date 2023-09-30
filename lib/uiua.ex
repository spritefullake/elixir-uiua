defmodule Uiua do
  @moduledoc """
  Documentation for `Uiua`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Uiua.hello()
      :world

  """
  def hello do
    :world
  end

  @reg ~r/[^\d|\s\[\]]|[[:alnum:]]+|\[.*]/u

  def parse(str) do
    Regex.scan(@reg, str)
  end

  def add(x, y) do
    x + y
  end

  def subtract(x, y) do
    x - y
  end

  def range(x) do
    Range.new(0, x - 1) |> Enum.to_list()
  end

  def restack(indices, stack) do
    top = for index <- indices do
      Enum.at(stack, index)
    end

    new_stack = Enum.with_index(stack, fn x, stack_index ->
      if Enum.member?(indices, stack_index) do
        nil
      else
        x
      end
    end) |> Enum.filter(fn x -> x != nil end)
    |> Enum.drop(Enum.min(indices))

    top ++ new_stack
  end

  def duplicate(stack) do
    restack([0,0], stack)
  end

  def over(stack) do
    restack([1,0,1], stack)
  end

  def flip(stack) do
    restack([1,0], stack)
  end

  def pop(stack) do
    restack([1], stack)
  end

  def roll(stack) do
    restack([1,2,0], stack)
  end

  def unroll(stack) do
    restack([2,0,1], stack)
  end

  def noop(_stack) do
    nil
  end


  @keymap %{
    "+" => &__MODULE__.add/2,
    "-" => &__MODULE__.subtract/2,
    "⇡" => &__MODULE__.range/1,
    "⇌" => &Enum.reverse/1,
    "." => &__MODULE__.duplicate/1,
    "," => &__MODULE__.over/1,
    "·" => &__MODULE__.noop/1
  }

  def eval(terms) do
    stack = []
    terms = Enum.reverse(List.flatten(terms))

    for i <- terms, reduce: stack do
      acc ->
        cond do
          Regex.match?(~r/\[.*\]/, i) ->
            result = i |> String.replace("[", "") |> String.replace("]", "") |> String.split()
            [eval(result) | acc]

          Regex.match?(~r/\d+/, i) ->
            [String.to_integer(i) | acc]

          Map.has_key?(@keymap, i) ->
            func = Map.get(@keymap, i)
            arity = :erlang.fun_info(func)[:arity]
            args = Enum.take(acc, arity)
            [apply(func, args) | Enum.drop(acc, arity)]

          true ->
            nil
        end
    end
  end
end
