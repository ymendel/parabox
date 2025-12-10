function levels_init()
  local level
  levels={}

  level=[[
#######
#.....#
#.*P..#
#...O.#
#.....#
#.....#
#######]]
  add(levels,level)

  level=[[
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
  add(levels,level)

    level=[[
#########
#####...#
#P.*....#
#.......#
#.......#
#.......#
#....O..#
#########]]
  add(levels,level)

    level=[[
#########
#####...#
#P.*..#.#
###.#...#
###...###
#####.###
#####O###
#########]]
  add(levels,level)
end

function parse_level(level_str)
  local lines=split(level_str,"\n")

  local level={
    lines=lines,
    cols=#lines[1],
    rows=#lines,
  }
  return level
end

function level_init()
  level=parse_level(levels[lnum])
  mw=level.cols
  mh=level.rows

  won=false
  tgts={}
  boxes={}
  undo_stack={}

  map_init()
  player_init(player_pos)
end
