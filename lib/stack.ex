defmodule Stack do


  @spec pairwise_operate(function(), list(), list()) :: list
  def pairwise_operate(func, first, second) do
    for i <- 0..(Enum.count(first) - 1) do
      apply(func, [Enum.at(first, i), Enum.at(second, i)])
    end
    |> List.flatten()
  end

  @spec pervasive_operate(function(), any, list()) :: list
  def pervasive_operate(func, first, second) do
    for i <- second do
      apply(func, [first, i])
    end
    |> List.flatten()
  end

  @spec same_size_lists(list(), list()) :: boolean
  def same_size_lists(x, y) do
    is_list(y) and is_list(x) and Enum.count(x) == Enum.count(y)
  end

  def only_first_elem_not_list_rest_same_size([first | rest]) do
    Kernel.not(is_list(first)) and same_size_lists(rest)
  end

  @spec elementwise_operate(function(), [list]) :: list
  def elementwise_operate(func, args) do
    for elems <- List.zip(args) do
      apply(func, elems |> Tuple.to_list())
    end
  end

  @spec same_size_lists(list()) :: boolean
  def same_size_lists(args) do
    # if any element of the list is NOT a list
    if args |> Enum.reject(&is_list/1) == [] do
      if args |> Enum.reject(fn x -> is_list(x) end) == [] do
        sizes = args |> Enum.map(&Enum.count/1)

        if sizes |> Enum.uniq() |> Enum.count() == 1 do
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def arrayize(func, first, second) do
    cond do
      same_size_lists(first, second) ->
        pairwise_operate(func, first, second)

      is_list(second) ->
        pervasive_operate(func, first, second)

      true ->
        func.(first, second)
    end
  end

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
