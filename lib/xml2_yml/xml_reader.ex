defmodule Xml2Yml.XmlReader do
  @moduledoc false

  alias Xml2Yml.YmlComposer

  import Xml2Yml.XmerlHelper
  require Record

  def load_xml(opts) do
    input_filepath = Keyword.fetch!(opts, :input_filepath)
    output_filepath = Keyword.fetch!(opts, :output_filepath)
    desired_tag = Keyword.fetch!(opts, :desired_tag)
    final_tag = Keyword.fetch!(opts, :final_tag)

    YmlComposer.begin(0, output_filepath)
    scan_xml(input_filepath, desired_tag, final_tag)
    :ok
  end

  def scan_xml(input_filepath, desired_tag, final_tag) do
    scan_options = [{:space, :normalize}] ++ xmerl_callbacks(desired_tag, final_tag)
    {doc, _rest} = :xmerl_scan.file(input_filepath, scan_options)
    IO.puts byte_size(inspect(doc))
  end

  defp xmerl_callbacks(desired_tag, final_tag) do
    [
      acc_fun: fn
        entity, acc, xstate when is_xmlElement?(entity) ->
          case xmlElement(entity, :name) do
            ^desired_tag ->
              YmlComposer.write(0, entity)
              {[], xstate}
            ^final_tag ->
              YmlComposer.finish(0)
              {[], xstate}
            _ ->
              {[entity | acc], xstate}
          end
        entity, acc, xstate ->
          {[entity | acc], xstate}
      end,
    ]
  end
end
