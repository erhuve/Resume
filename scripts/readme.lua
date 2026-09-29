local function html(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "html", {wrap_text = "none"})
end

function SmallCaps(element)
  return element.content
end

function Underline(element)
  return element.content
end

function Span(element)
  if element.identifier == "" and #element.classes == 0 then
    return element.content
  end
end

function Link(element)
  element.content = element.content:walk({
    Link = function(nested) return nested.content end
  })
  return element
end

function Header(element)
  element.level = element.level + 1
  return element
end

function Div(element)
  if element.classes:includes("center") then
    local title = pandoc.List()
    local contacts = pandoc.List()
    local after_break = false
    for _, inline in ipairs(element.content[1].content) do
      if inline.t == "LineBreak" then
        after_break = true
      elseif after_break then
        contacts:insert(inline)
      else
        title:insert(inline)
      end
    end
    local heading = html({pandoc.Header(1, title)}):gsub("<h1[^>]*>", '<h1 align="center">')
    local links = html({pandoc.Para(contacts)}):gsub("<p>", '<p align="center">')
    return pandoc.RawBlock("html", heading .. "\n" .. links)
  end
end

function BulletList(element)
  local contains_tables = false
  for _, item in ipairs(element.content) do
    if item[1] and item[1].t == "Table" then contains_tables = true end
  end
  if contains_tables then
    local blocks = pandoc.List()
    for _, item in ipairs(element.content) do
      blocks:extend(item)
    end
    return blocks
  end
  for _, item in ipairs(element.content) do
    for index, block in ipairs(item) do
      if block.t == "Para" then item[index] = pandoc.Plain(block.content) end
    end
  end
  return element
end

local function render_table(element)
  local rows = pandoc.List()
  rows:extend(element.head.rows)
  for _, body in ipairs(element.bodies) do
    rows:extend(body.head)
    rows:extend(body.body)
  end
  rows:extend(element.foot.rows)
  local output = {"<table>"}
  for _, row in ipairs(rows) do
    table.insert(output, "<tr>")
    for index, cell in ipairs(row.cells) do
      local align = index == #row.cells and "right" or "left"
      table.insert(output, '<td align="' .. align .. '">' .. html(cell.contents) .. "</td>")
    end
    table.insert(output, "</tr>")
  end
  table.insert(output, "</table>")
  return pandoc.RawBlock("html", table.concat(output, "\n"))
end

return {
  {SmallCaps = SmallCaps, Underline = Underline, Span = Span, Link = Link},
  {Header = Header, Div = Div, BulletList = BulletList},
  {Table = render_table}
}
