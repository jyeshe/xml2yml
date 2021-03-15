defmodule Xml2Yml.YmlComposer do
  @moduledoc false
  use GenServer

  import Xml2Yml.XmerlHelper
  require Record

  defstruct [file: nil]

  alias __MODULE__, as: State

  @pad "  "

  def child_spec(id: id) do
    %{
      id: id |> process_name(true),
      start: {__MODULE__, :start_link, [[id: id]]}
    }
  end

  def start_link(id: id) do
    GenServer.start_link(__MODULE__, :ok, name: process_name(id))
  end

  def init(:ok) do
    {:ok, %State{}}
  end

  def begin(server_id, filepath) do
    process_name(server_id)
    |> GenServer.cast({:begin, filepath})
  end

  def finish(server_id) do
    IO.inspect :finish
    process_name(server_id)
    |> GenServer.cast(:finish)
  end

  def write(server_id, element) do
    process_name(server_id)
    |> GenServer.cast({:element, element})
  end

  def handle_cast({:begin, filepath}, %State{file: file}) do
    if file, do: File.close(file)
    file = File.open!(filepath, [:write, :utf8])

    {:noreply, %State{file: file}}
  end

  def handle_cast(:finish, %State{file: file}) do
    File.close(file)
    {:noreply, %State{}}
  end

  def handle_cast({:element, element}, state = %State{file: file}) do
    write_entity(element, 0, file)
    {:noreply, state}
  end

  def write_entity([], _depth, _file), do: :ok

  def write_entity(entity, depth, file) when is_xmlText?(entity) do
    value = xmlText(entity, :value)
    if value != ' ' do
      value = :binary.list_to_bin(value)
      IO.write file, padding(depth) <> "_text: #{value}\n"
    end
  end

  def write_entity(element, depth, file) do
    # tag name
    element_atom = xmlElement(element, :name)
    element_name = padding(depth) <> Atom.to_string(element_atom) <> ":\n"

    # tag attributes
    left_padding = padding(depth+1)
    attributes =
      get_attribute_keywords(element)
      |> Enum.reduce("", fn {name, value}, acc ->
        acc <> left_padding <> "#{Atom.to_string(name)}: #{value}\n"
      end)

    IO.write(file, element_name)
    IO.write(file, attributes)

    xmlElement(element, :content)
    |> Enum.each(fn e -> write_entity(e, depth+1, file) end)
  end

  #
  # Internal
  #
  defp process_name(id, is_new? \\ false) do
    name_str = "ymlcomposer#{id}"

    if is_new? do
      String.to_atom(name_str)
    else
      String.to_existing_atom(name_str)
    end
  end

  defp padding(depth) do
    String.duplicate(@pad, depth)
  end
end
