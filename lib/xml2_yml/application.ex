defmodule Xml2Yml.Application do
  @moduledoc false

  use Application

  import Xml2Yml.XmlReader

  @input  "test/input.xml"
  @output "output.yml"

  def start(_type, _args) do
    children = [
      {Xml2Yml.YmlComposer, id: 0}
    ]

    opts = [strategy: :one_for_one, name: Xml2Yml.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(phase, _start_type, _phase_args) do
    if phase == :load_xml do
      [
        input_filepath: @input,
        output_filepath: @output,
        desired_tag: :matchup,
        final_tag: :matchups,
      ]
      |> load_xml()
    end
  end
end
