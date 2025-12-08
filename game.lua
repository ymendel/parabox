function levels_init()
  levels={}

  local level1=[[
XXXXXXXXXXX
X.........X
X.b..b....X
X..P......X
X....X....X
X..Xb.....X
X.........X
X....XX...X
X.........X
X.........X
XXXXXXXXXXX]]

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

function game_init()
  levels_init()
  level=parse_level(levels[1])
  mw=level.cols
  mh=level.rows

  won=false
  tgts={}
  boxes={}

  map_init()
  player_init(player_pos)
end

function game_update()
  if (won) then
    state="win"
    handle_state()
    return
  end
  player_update()
  check_tgts()
end

function game_draw()
  cls()
  camera(-20,-20)
  level_draw()
  boxes_draw()
  tgts_draw()
  player_draw()
  camera()
end

function level_draw()
  map(0,0,0,0,mw,mh)
  rect(-2,-2,mw*8,mh*8,7)
end

function boxes_draw()
  for box in all(boxes) do
    local coords=map_to_screen_coords(box.x,box.y)
    pal(box.pal)
    spr(box.spr,coords[1],coords[2])
  end
  pal()
end

function tgts_draw()
  for tgt in all(tgts) do
    local coords=map_to_screen_coords(tgt.x,tgt.y)
    rectdim(coords[1],coords[2],7,7,7)
  end
end

function push_boxes(pusher,dx,dy)
  for box in all(boxes) do
    if (pusher~=box and pusher.x==box.x and pusher.y==box.y) then
      local px,py=box.x,box.y
      box.x+=dx
      box.y+=dy
      local tile=mget(box.x,box.y)
      if (tile_blocking(tile)) then
        box.x,box.y=px,py
        return -1
      else
        local err=push_boxes(box,dx,dy)
        if (err==-1) then
          box.x,box.y=px,py
          return -1
        end
      end
    end
  end
end

function pl_on_box()
  for box in all(boxes) do
    if (pl.x==box.x and pl.y==box.y) then
      return true
    end
  end
  return false
end

function map_init()
  local pals={
    {[1]=1,[12]=12},
    {[1]=8,[12]=14},
    {[1]=3,[12]=11},
    {[1]=2,[12]=8}
  }
  local pos_tgts={}

  for j=1,level.rows do
    local line=level.lines[j]
    -- printh(line,"blah")
    for i=1,level.cols do
      local char=sub(line,i,i)
      -- printh(char,"blah")

      local mx,my=i-1,j-1
      local tile=17

      if (char=="X") then
        tile=16
      elseif (char=="b") then
        local nb={
          spr=2,
          pal=rnd(pals),
          x=mx,
          y=my,
        }
        add(boxes,nb)
      elseif (char==".") then
        add(pos_tgts, {x=mx,y=my})
      elseif (char=="P") then
        player_pos={x=mx,y=my}
      end

      mset(mx,my,tile)
    end
  end

  for box in all(boxes) do
    local tgt=rnd(pos_tgts)
    add(tgts,tgt)
    del(pos_tgts,tgt)
  end
end

function tile_blocking(tile)
  return fget(tile,1)
end

function tile_moveable(tile)
  return fget(tile,2)
end

function check_tgts()
  for tgt in all(tgts) do
    if (not tgt_has_box(tgt)) then
      return false
    end
  end

  won=true
end

function tgt_has_box(tgt)
  for box in all(boxes) do
    if (same_position(box,tgt)) return true
  end

  return false
end

function same_position(a,b)
  return a.x==b.x and a.y==b.y
end

function win_init()
  -- anything to do here?
  print("yayyyyyyyyyy",10,10,10)
end

function win_update()
  -- anything to do here?
end

function win_draw()
  -- anything to do here?
end
