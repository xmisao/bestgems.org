def abbr(text, limit = 2048)
  return "" unless text

  return text unless text.length > limit

  text[0, limit] + "..."
end
