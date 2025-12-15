function game_init()
  lnum=lnum or 2
  levels_init()
  level_init()
end

function game_update()
  if (won) then
    state="win"
    handle_state()
    return
  end
  player_update()
  check_tgts()
  undo_update()
end

function undo_update()
  if (btnp(🅾️)) then
    local u=deli(undo_stack)
    do_undo(u)
  end
end

function do_undo(u)
  if (u) then
    -- TODO: see if this can work, or if facing should be recorded
    local dx=pl.pos.x-u.pl.x
    if (dx<0) then
      pl.xf=true
    elseif (dx>0) then
      pl.xf=false
    end
    pl.pos=tab_dupe(u.pl)
    for i,ubox in pairs(u.boxes) do
      local box=boxes[i]
      box.pos=tab_dupe(ubox)
    end
  end
end

function record_undo()
  local box_info={}
  for i,box in ipairs(boxes) do
    if (has_moved(box)) box_info[i]=tab_dupe(box.prevpos)
  end

  local nu={
    pl=tab_dupe(pl.prevpos),
    boxes=box_info,
  }
  add(undo_stack,nu)
end

function game_draw()
  cls()
  -- camera(-64+mw*4,-64+mh*4)
  level_draw()
  boxes_draw()
  tgts_draw()
  player_draw()
  camera()
end

function level_draw()
  -- add(debug,tab_to_string({mx=mx,my=my,mw=mw,mh=mh}))
  -- map(mx,my,0,0,mw,mh)
  map()
  -- rect(-2,-2,mw*8,mh*8,7)
end

function boxes_draw()
  foreach(boxes,draw_box)
end

function draw_box(box)
  local coords=pos_to_screen_coords(box.pos)
  -- pal(box.pal)
  -- spr(box.spr,coords[1],coords[2])
  if (box.sublevel) then
    rectdim(coords[1],coords[2],7,7,3,true)
    draw_sublevel(box.sublevel,coords[1],coords[2])
  else
    rectdim(coords[1],coords[2],7,7,12,true)
  end
end

function draw_sublevel(sublevel,x,y)
  sublevel_offset_parse=function(char,mpos)
    ox,oy=x,y
    oy+=(7-sublevel.rows)\2
    do_sublevel_parse(char,mpos)
  end

  map_parse(sublevel,sublevel_offset_parse)
end

function do_sublevel_parse(char,mpos)
  local color=11
  local sublevel=level.sublevels[char]

  if (char=="#") then
    color=3
  elseif (char=="*") then
    color=12
  elseif (char=="O") then
    color=6
  elseif (char=="@") then
    -- hmmmmm
    -- add_box(mpos)
    -- add_tgt(mpos)
  elseif (char=="P") then
    color=14
  elseif (sublevel) then
    color=3
  end

  pset(mpos.x+ox,mpos.y+oy,color)
end

function tgts_draw()
  for tgt in all(tgts) do
    local coords=pos_to_screen_coords(tgt.pos)
    local c=tgt.box and 7 or 6
    rectdim(coords[1],coords[2],7,7,c)
  end
end

function handle_box_push()
  foreach(boxes,record_pos)
  push_boxes(pl,pl.dx,pl.dy)
  for tgt in all(tgts) do
    tgt.box=tgt_has_box(tgt)
  end
end

function push_boxes(pusher,dx,dy)
  -- printh("\npusher "..tab_to_string(pusher.pos),"blah")
  -- add(debug,tab_to_string(pusher.pos))
  for box in all(boxes) do
    -- printh("box "..tab_to_string(box.pos),"blah")
    if (pusher~=box and same_position(pusher,box)) then
      move(box,dx,dy)
      local tile=pos_tile(box.pos)
      if (tile_blocking(tile)) then
        revert_move(box)
        return -1
      else
        local err=push_boxes(box,dx,dy)
        if (err==-1) then
          revert_move(box)
          return -1
        end
      end
    end
  end
end

function move(mvr,dx,dy)
  mvr.pos.x+=dx
  mvr.pos.y+=dy
end

function record_pos(mvr)
  mvr.prevpos=tab_dupe(mvr.pos)
end

function revert_move(mvr)
  mvr.pos=mvr.prevpos
end

function has_moved(mvr)
  return not tab_equal(mvr.pos,mvr.prevpos)
end

function enter_sublevel(sublevel,mvr,dx,dy)
  -- determine entrance = middle of the side entered
  -- NOTE: keep sublevels odd dimensions
  local maxx,maxy=sublevel.cols,sublevel.rows
  local midx,midy=maxx\2,maxy\2

  local entr={}
  if (dx==1) then
    entr={x=0,y=midy}
  elseif (dx==-1) then
    entr={x=maxx,y=midy}
  elseif (dy==1) then
    entr={x=midx,y=0}
  elseif (dy==-1) then
    entr={x=midx,y=maxy}
  end
  mvr.pos=entr
  mvr.pos.level=sublevel.key

  -- add(debug,tab_to_string(entr))
  if (mvr==pl) then
    -- add(debug,"hello?")
    mx,my=sublevel.x,sublevel.y
    mw,mh=sublevel.rows,sublevel.cols
  end
end

function pl_on_box()
  for box in all(boxes) do
    if (same_position(pl,box)) then
      return box
    end
  end
  return false
end

function map_parse(map, callback)
  for j=1,map.rows do
    local line=map.lines[j]
    for i=1,map.cols do
      local char=sub(line,i,i)

      local mx,my=i-1,j-1
      local mpos={x=mx,y=my}

      callback(char,mpos)
    end
  end
end

function map_init()
  parsing_level="main"
  -- printh("parsing level "..parsing_level, "blah")
  ox,oy=level.map.x,level.map.y
  map_parse(level.map,do_mapset_parse)

  for k,sublevel in pairs(level.sublevels) do
    sublevel_parse=function(char,mpos)
      parsing_level=k
      -- printh("parsing level "..parsing_level, "blah")
      ox,oy=sublevel.x,sublevel.y
      do_mapset_parse(char,mpos)
    end

    map_parse(sublevel,sublevel_parse)
  end
end

function do_mapset_parse(char,mpos)
  local tile=17
  local sublevel=level.sublevels[char]

  if (char=="#") then
    tile=16
  elseif (char=="*") then
    add_box(mpos)
  elseif (char=="O") then
    add_tgt(mpos)
  elseif (char=="@") then
    add_box(mpos)
    add_tgt(mpos)
  elseif (char=="P") then
    player_pos=mpos
  elseif (sublevel) then
    add_box(mpos,sublevel)
  end

  mset(mpos.x+ox,mpos.y+oy,tile)
end

function add_box(mpos,sublevel)
  local pos=tab_dupe(mpos)
  pos.level=parsing_level
  local nb={
    spr=2,
    pos=pos,
    sublevel=sublevel,
  }
  add(boxes,nb)
end

function add_tgt(mpos)
  local pos=tab_dupe(mpos)
  pos.level=parsing_level
  local nt={
    pos=pos
  }
  add(tgts,nt)
end

function tile_blocking(tile)
  return fget(tile,1)
end

function tile_moveable(tile)
  return fget(tile,2)
end

function check_tgts()
  for tgt in all(tgts) do
    if (not tgt.box) then
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
  return tab_equal(a.pos,b.pos)
end

function win_init()
  print("yayyyyyyyyyy",10,10,10)
  print("press ❎ to continue")
end

function win_update()
  if (btnp(❎)) then
    lnum+=1
    state="game"
    handle_state()
    return
  end
end

function win_draw()
  -- anything to do here?
end
