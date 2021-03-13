defmodule Xml2Yml.XmerlHelper do

  require Record

  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  defmacro is_xmlElement?(entity) do
    quote do: Record.is_record(unquote(entity), :xmlElement)
  end

  defmacro is_xmlText?(entity) do
    quote do: Record.is_record(unquote(entity), :xmlText)
  end

  def get_attribute_keywords(element) do
    xmlElement(element, :attributes)
    |> Enum.map(fn attr ->
      name = xmlAttribute(attr, :name)
      value = xmlAttribute(attr, :value) |> :binary.list_to_bin()
      {name, value}
    end)
  end
end
