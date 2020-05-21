defmodule JeopardyWeb.PageView do
  use JeopardyWeb, :view
  alias Phoenix.HTML.Form

  def text_inputx(form, field, opts \\ []) do
    Form.text_input(form, field, opts ++ Form.input_validations(form, field))
  end
end
