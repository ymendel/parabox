function init_debug()
  debug={}
end

function draw_debug()
  cursor(2,2,10)
  for d in all(debug) do
    print("\#0"..d)
  end
end

function map_to_screen_coords(x,y)
  return {x*8,y*8}
end

function pos_to_screen_coords(pos)
  return map_to_screen_coords(pos.x,pos.y)
end

function rectdim(x,y,w,h,col,fill)
  local rectfn=fill and rectfill or rect
  rectfn(x,y,x+w-1,y+h-1,col)
end

function pos_tile(pos)
  return mget(pos.x,pos.y)
end

-- NOTE: these are all shallow checks/dupes.
-- I don't need more at the moment
function tab_dupe(table)
  local nt={}
  for k,v in pairs(table) do
    nt[k]=v
  end
  return nt
end

function arr_equal(a,b)
  if (#a~=#b) return false
  for i=1,#a do
    if (a[i]~=b[i]) return false
  end
  return true
end

function tab_equal(a,b)
  local akeys=tab_keys(a)
  local bkeys=tab_keys(b)

  if (not arr_equal(akeys,bkeys)) return false

  for k in all(akeys) do
    if (a[k]~=b[k]) return false
  end

  return true
end

function tab_keys(table)
  local keys={}
  for k,v in pairs(table) do
    add(keys,k)
  end
  return keys
end

function tab_to_string(table)
  local output=""
  for k,v in pairs(table) do
    output..=k..":"..v.."  "
  end
  return output
end
