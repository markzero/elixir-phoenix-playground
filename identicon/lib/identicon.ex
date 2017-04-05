defmodule Identicon do
  @moduledoc """
    Image manipulation to generate Identicons.
  """


  @doc """
    Main entry.

    ## Test

      iex> %Identicon.Image{color: col, hex: _hx} = Identicon.main("apples")
      iex> col
      {218, 236, 207}
  """
  def main(input) do
    hash_input(input)
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end


  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end


  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    # don't need arg=image here as we don't need image var here anymore
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn({top_left, bottom_right}) ->
      # here image gets transformed (Erlang's function does it)
      # unlike Elixir's immutable behavior
      :egd.filledRectangle(image, top_left, bottom_right, fill)
    end)

    :egd.render(image)
  end



  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn({_code, index} = _square) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end


  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({code, _index} = _square) -> rem(code, 2) == 0 end)
    %Identicon.Image{image | grid: grid}
  end


  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
        |> Enum.chunk(3) # this is actually Enum.chunk(hex, 3), pipe doesn't need 1st param
        |> Enum.map(&mirror_row/1) # pass by reference, otherwise mirror_row will be actually called
        |> List.flatten
        |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end


  def mirror_row(row) do
    # [145, 46, 200] => [145, 46, 200, 46, 145]
    [first, second | _tail] = row
    row ++ [second, first]
  end


  @doc """
    Pick color.

    ## Test

      iex> image = Identicon.hash_input("apples")
      iex> color = Identicon.pick_color(image)
      iex> {r, g, b} = color.color
      iex> {r, g, b}
      {218, 236, 207}
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # image already has `hex` from hash_input method
    # this is equivalent to Map.put
    # so for example: colors = %{primary: "red"}
    # to get update: %{colors | primary: "blue"}
    %Identicon.Image{image | color: {r, g, b}}
  end



  @doc """
    Create `Identicon.Image` out of random string as input.

  ## Example

      iex> image = Identicon.hash_input("apples")
      iex> %Identicon.Image{hex: [r, g, b | _tail]} = image
      iex> [r, g, b]
      [218, 236, 207]
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
