function levels_init()
  local level_map
  local sublevel_map
  levels={}

  level_map=[[
#######
#.....#
#.*P..#
#...O.#
#.....#
#.....#
#######]]
  add(levels,level_map)

  level_map=[[
###########
#.........#
#.*..*....#
#...P....O#
#....#....#
#..#*.....#
#.........#
#....##..O#
#.........#
#...O.....#
###########]]
  -- add(levels,level_map)

  level_map=[[
#########
#####...#
#P.*....#
#.......#
#.......#
#.......#
#....O..#
#########]]
  add(levels,level_map)

  level_map=[[
#########
#####...#
#P.*..#.#
###.#...#
###...###
#####.###
#####O###
#########]]
  -- add(levels,level_map)

  level_map=[[
#########
#P.a...##
#.......#
#.......#
#.......#
#.......#
#########]]
  sublevel_map=[[
#######
#.....#
...*..#
#...O.#
#######]]
  add(levels,{map=level_map,sublevels={a=sublevel_map}})

  level_map=[[
#########
#P.*...##
#.......#
#.......#
#.......#
#....O..#
#########]]
  add(levels,level_map)
end

function parse_level(level_info)
  local ltype=type(level_info)

  local map={}
  local sublevels={}
  if ltype=="string" then
    map=parse_level_map(level_info)
  elseif ltype=="table" then
    map=parse_level_map(level_info.map)
    local x,y=0,0
    x+=map.cols+1
    for k,v in pairs(level_info.sublevels) do
      -- TODO: handle wrapping when map goes too wide
      local submap=parse_level_map(v,x,y)
      submap.key=k
      x+=submap.cols+1
      sublevels[k]=submap
    end
  end

  return {map=map,sublevels=sublevels}
end

function parse_level_map(level_map,x,y)
  local lines=split(level_map,"\n")

  local map={
    lines=lines,
    cols=#lines[1],
    rows=#lines,
    x=x or 0,
    y=y or 0,
  }
  return map
end

function level_init()
  level=parse_level(levels[lnum])
  mx,my=level.map.x,level.map.y
  mw,mh=level.map.cols,level.map.rows

  won=false
  tgts={}
  boxes={}
  undo_stack={}

  map_init()
  player_init(player_pos)
end
