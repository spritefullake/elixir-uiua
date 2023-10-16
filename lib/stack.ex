defmodule Stack do
  @moduledoc """
  The stack module defines the basic list of elements (aka an array, or a "stack")
  that the Uiua language operates with.
  """

  @spec only_first_elem_not_list_rest_same_size([...]) :: boolean
  def only_first_elem_not_list_rest_same_size([first | rest]) do
    Kernel.not(is_list(first)) and same_size_lists(rest)
  end

  @doc"""
  Pairs elements in lists and applies the function to them"""
  @spec pairwise_operate((a, b -> any()), [a], [b]) :: list when a: var, b: var
  def pairwise_operate(func, first, second) do
    for i <- 0..(Enum.count(first) - 1) do
      apply(func, [Enum.at(first, i), Enum.at(second, i)])
    end
    |> List.flatten()
  end

  @doc"""
  Applies a single element across the whole list. For example ```+ 3 [1,2,3,4]```
  """
  @spec elementwise_operate((a -> any()), [a]) :: list when a: var
  def elementwise_operate(func, args) do
    for elems <- List.zip(args) do
      apply(func, elems |> Tuple.to_list())
    end
  end

  @spec same_size_lists(list()) :: boolean
  def same_size_lists(args) do
    if args |> Enum.reject(&is_list/1) == [] do
      # make sure lists are the same size
      args |> Enum.map(&Enum.count/1) |> Enum.uniq() |> Enum.count() == 1
    else # if not all the items are lists
      false
    end
  end


  @spec arrayize(function(), list()) :: list()
  def arrayize(func, args) do
    cond do
      same_size_lists(args) ->
        elementwise_operate(func, args)

      only_first_elem_not_list_rest_same_size(args) ->
        [first | rest] = args
        rest_lists_length = Enum.count(List.first(rest))

        new_first =
          for _i <- 0..(rest_lists_length - 1) do
            first
          end

        elementwise_operate(func, [new_first | rest])

      true ->
        apply(func, args)
    end
  end

  @spec stack_apply(function(), list()) :: [...]
  def stack_apply(func, stack) do
    arity = :erlang.fun_info(func)[:arity]
    arguments = Enum.take(stack, arity)
    rest = Enum.drop(stack, arity)
    [arrayize(func, arguments) | rest]
  end

  # This macro defines functions for use with the stack automatically
  defmacro defstack({name, context, arguments} = clause, do: expression) do
    quote do
      def unquote(name)(stack) when is_list(stack) do
        unquote(__MODULE__).stack_apply(&(__MODULE__.unquote(name) / unquote(Enum.count(arguments))), stack)
      end

      def unquote(clause) do
        unquote(expression)
      end
    end
  end

  defmacro __using__(_opts) do
    alias Stack
    quote do
      def defstack(clause, do: expression) do
        defstack(clause, do: expression)
      end
    end
  end
end
