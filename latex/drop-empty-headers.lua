-- Quarto books emit a \chapter{} for every file listed in `chapters:`,
-- even when the file has no PDF-visible content (e.g. index.qmd, which is
-- an HTML-only landing page). That produces a stray empty chapter in the
-- PDF. This filter drops any Header that has no inline content.
function Pandoc(doc)
  local kept = {}
  for _, block in ipairs(doc.blocks) do
    if not (block.t == "Header" and #block.content == 0) then
      table.insert(kept, block)
    end
  end
  doc.blocks = kept
  return doc
end
