function levels_init()
  levels={}

  local level1=[[
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

  add(levels,level1)
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
  level=parse_level(levels[1])
  mw=level.cols
  mh=level.rows

  won=false
  tgts={}
  boxes={}

  map_init()
  player_init(player_pos)
end
