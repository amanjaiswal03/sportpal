defmodule Sportpal.Identicon do
  @moduledoc """
    Documentation for `Sportpal.Identicon`
  """

  defmodule Image do
    defstruct hex: nil, color: nil, grid: nil, pixel_map: nil
  end

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_grids
    |> build_pixel_map
    |> draw_image
    # TODO: Remove `Sportpal.Identicon.save_image/2`. And save the image in your database
    |> save_image(input)
  end

  @doc """
    Saves `provided_input_string.png` file in the directory
  """
  def save_image(image, input) do
    dir_path = "tmp/"

    with :ok <- File.mkdir_p!(Path.dirname(dir_path)) do
      File.write(dir_path <> "#{input}.png", image)
    else
      _ ->
        IO.puts("Error while saving file")
    end
  end

  @doc """
    Draws the identicon

    Experiencing problem with `:edg`

    Step 1: Add `:edg` as your dependency. (See- `https://github.com/erlang/egd`)

    In your `mix.exs`

      defp deps do
        [
          {:egd, github: "erlang/egd"}
        ]
      end

    Step 2: Install rebar, the erlang build tool, as this library depends on rebar.

    Run `mix local.rebar --force` to install rebar (and rebar3). (See - `https://www.reddit.com/r/elixir/comments/719tdf/erlang_egd_not_working_inside_elixir_on_windows/`)

    Step 3: Re-open your terminal and run the following inside the project folder

      mix deps.clean --all
      mix deps.get
      mix deps.compile

  """
  def draw_image(%Sportpal.Identicon.Image{pixel_map: pixel_map, color: color}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    pixel_map
    |> Enum.each(fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  @doc """
    Updates `:pixel_map` of `Sportpal.Identicon.Image` using its value of `:grid`

    Note:

    The `:grid` has to be a list of tuples of integers. It cannot be `nil` or empty

    ## Examples

        iex> image = %Sportpal.Identicon.Image{color: nil, hex: [28, 178, 81], grid: [{28, 0}, {178, 1}, {81, 2}, {178, 3}, {28, 4}], pixel_map: nil}
        iex> Sportpal.Identicon.build_pixel_map(image)
        %Sportpal.Identicon.Image{color: nil, hex: [28, 178, 81], grid: [{28, 0}, {178, 1}, {81, 2}, {178, 3}, {28, 4}], pixel_map: [{{0, 0}, {50, 50}}, {{50, 0}, {100, 50}}, {{100, 0}, {150, 50}}, {{150, 0}, {200, 50}}, {{200, 0}, {250, 50}}]}
  """
  @spec build_pixel_map(
          image :: %Sportpal.Identicon.Image{
            hex: [integer(), ...],
            grid: [{integer(), integer()}, ...],
            pixel_map: nil
          }
        ) :: %Sportpal.Identicon.Image{
          hex: [integer(), ...],
          grid: [{integer(), integer()}, ...],
          pixel_map: [{{integer(), integer()}, {integer(), integer()}}, ...]
        }
  def build_pixel_map(%Sportpal.Identicon.Image{grid: grid} = image) do
    pixel_map =
      grid
      |> Enum.map(fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Sportpal.Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Removes odd `:grid` value

    ## Examples

        iex> image = %Sportpal.Identicon.Image{color: nil, grid: [{28, 0}, {178, 1}, {81, 2}, {178, 3}, {28, 4}], hex: nil}
        iex> Sportpal.Identicon.filter_odd_grids(image)
        %Sportpal.Identicon.Image{color: nil, grid: [{28, 0}, {178, 1}, {178, 3}, {28, 4}], hex: nil}
  """
  @spec filter_odd_grids(
          image :: %Sportpal.Identicon.Image{
            grid: [{integer(), integer()}, ...]
          }
        ) :: %Sportpal.Identicon.Image{
          grid: [{integer(), integer()}, ...]
        }
  def filter_odd_grids(%Sportpal.Identicon.Image{grid: grid} = image) do
    grid =
      grid
      |> Enum.filter(fn {code, _index} ->
        rem(code, 2) == 0
      end)

    %Sportpal.Identicon.Image{image | grid: grid}
  end

  @doc """
    Updates value of `:grid` of `Sportpal.Identicon.Image` using its value of `:hex`

    Note:

    The `:hex` has to be a list of numbers. It cannot be `nil` or empty

    ## Examples

        iex>image = %Sportpal.Identicon.Image{color: nil, grid: nil, hex: [28, 178, 81]}
        iex> Sportpal.Identicon.build_grid(image)
        %Sportpal.Identicon.Image{color: nil, grid: [{28, 0}, {178, 1}, {81, 2}, {178, 3}, {28, 4}], hex: [28, 178, 81]}
  """
  @spec build_grid(
          image :: %Sportpal.Identicon.Image{
            hex: [integer(), ...],
            grid: nil
          }
        ) :: %Sportpal.Identicon.Image{
          hex: [integer(), ...],
          grid: [tuple(), ...]
        }
  def build_grid(%Sportpal.Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Sportpal.Identicon.Image{image | grid: grid}
  end

  @doc """
    Mirrors the first and second element in a list

    Returns the mirrored list

    ## Examples

        iex> Sportpal.Identicon.mirror_row([1, 2, 3])
        [1, 2, 3, 2, 1]
        iex> Sportpal.Identicon.mirror_row([1, 2, 3, 4, 5])
        [1, 2, 3, 4, 5, 2, 1]
  """
  @spec mirror_row(row :: [integer(), ...]) :: [integer(), ...]
  def mirror_row([first, second | _rest] = row) do
    row ++ [second, first]
  end

  @doc """
    Updates `:color` of `Sportpal.Identicon.Image` using its value of `:hex`

    Note:

    The `:hex` has to be a list of numbers. It cannot be `nil` or empty

    ## Examples

        iex> image = %Sportpal.Identicon.Image{hex: [28, 178, 81], grid: nil, color: nil}
        iex> Sportpal.Identicon.pick_color(image)
        %Sportpal.Identicon.Image{color: {28, 178, 81}, grid: nil, hex: [28, 178, 81]}
  """
  @spec build_grid(
          image :: %Sportpal.Identicon.Image{hex: [integer(), ...], grid: nil, color: nil}
        ) ::
          %Sportpal.Identicon.Image{hex: [integer(), ...], grid: nil, color: tuple()}
  def pick_color(%Sportpal.Identicon.Image{hex: [r, g, b | _rest]} = image) do
    %Sportpal.Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Returns the hash of any string

    See - `https://elixir-lang.org/getting-started/erlang-libraries.html#the-crypto-module`

    The `:crypto` module is part of the `:crypto` application that ships with Erlang

    This means you must list the `:crypto` application as an additional application in your project configuration

    To do this, edit your `mix.exs` file to include

      def application do
        [extra_applications: [:crypto]]
      end

    ## Examples

        iex> Sportpal.Identicon.hash_input("text")
        %Sportpal.Identicon.Image{hex: [28, 178, 81, 236, 13, 86, 141, 230, 169, 41, 181, 32, 196, 174, 216, 209]}
  """
  @spec hash_input(input :: String.t()) :: %Sportpal.Identicon.Image{}
  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Sportpal.Identicon.Image{hex: hex}
  end
end
