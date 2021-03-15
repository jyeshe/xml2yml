defmodule Xml2Yml.XmlReader do
  @moduledoc false

  alias Xml2Yml.YmlComposer

  import Xml2Yml.XmerlHelper
  require Record

  def load_xml(opts) do
    input_filepath = Keyword.fetch!(opts, :input_filepath)
    output_filepath = Keyword.fetch!(opts, :output_filepath)
    desired_tag = Keyword.fetch!(opts, :desired_tag)

    YmlComposer.begin(0, output_filepath)
    scan_xml(input_filepath, desired_tag)
    :ok
  end

  def scan_xml(input_filepath, desired_tag) do
    scan_options = [{:space, :normalize}] ++ xmerl_callbacks(desired_tag)
    {_doc, _rest} = :xmerl_scan.file(input_filepath, scan_options)
  end

  defp xmerl_callbacks(desired_tag) do
    [
      acc_fun: fn entity, acc, xstate ->
        if is_xmlElement?(entity) and xmlElement(entity, :name) == desired_tag do
          YmlComposer.write(0, entity)
          {[], xstate}
        else
          {[entity | acc], xstate}
        end
      end,
      close_fun: fn xstate ->
        YmlComposer.finish(0)
        xstate
      end
    ]
  end
end
