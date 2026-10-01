defmodule PrawnEx.AFMWidthTest do
  use ExUnit.Case, async: true

  alias PrawnEx.Text

  test "measures built-in fonts with their own AFM widths" do
    # Helvetica: H=722 e=556 l=222 l=222 o=556 -> 2278/1000 em
    assert_in_delta Text.width("Hello", 10, "Helvetica"), 22.78, 0.001
    # Helvetica-Bold: H=722 e=556 l=278 l=278 o=611 -> 2445/1000 em
    assert_in_delta Text.width("Hello", 10, "Helvetica-Bold"), 24.45, 0.001
    assert Text.width("Hello", 10, "Times-Roman") < Text.width("Hello", 10, "Helvetica")
  end

  test "measures Latin-1 and CP1252 characters after transliteration" do
    # ë = 556 and € = 556 in Helvetica
    assert_in_delta Text.width("ë€", 10, "Helvetica"), 11.12, 0.001
  end

  test "falls back to the estimate for unknown fonts" do
    assert Text.width("Hello", 10, "MyBrand") == Text.estimated_width("Hello", 10)
  end

  test "wraps with the given font's widths" do
    text = String.duplicate("WOMBAT ", 6)
    regular = Text.wrap_to_lines(text, 200, 12, "Helvetica")
    bold = Text.wrap_to_lines(text, 200, 12, "Helvetica-Bold")
    assert length(bold) >= length(regular)

    for line <- bold do
      assert Text.width(line, 12, "Helvetica-Bold") <= 200
    end
  end

  test "character spacing emits Tc" do
    binary =
      PrawnEx.Document.new()
      |> PrawnEx.add_page()
      |> PrawnEx.set_character_spacing(2)
      |> PrawnEx.text_at({10, 10}, "SPACED")
      |> PrawnEx.to_binary()

    assert binary =~ "2 Tc"
  end
end
