local listfunctions = {}

function listfunctions.contains(list, x)
  for i, y in ipairs(list) do
    if y == x then
      return true
    end
  end
  return false
end

return listfunctions