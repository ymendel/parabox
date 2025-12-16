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
  local sox,soy=x,y
  soy+=(7-sublevel.rows)\2

  sublevel_offset_parse=function(char,mpos)
    ox,oy=sox,soy
    do_sublevel_draw_parse(char,mpos)
  end

  map_parse(sublevel,sublevel_offset_parse)

  local plpos=pl.pos
  if (plpos.level==sublevel.key) then
    pset(plpos.x+sox,plpos.y+soy,14)
  end
  for box in all(boxes) do
    local bpos=box.pos
    if (bpos.level==sublevel.key) then
      pset(bpos.x+sox,bpos.y+soy,12)
    end
  end
end

function do_sublevel_draw_parse(char,mpos)
  local color=11
  local sublevel=level.sublevels[char]

  if (char=="#") then
    color=3
  elseif (char=="*") then
    -- color=12
  elseif (char=="O") then
    color=6
  elseif (char=="@") then
    -- hmmmmm
    -- add_box(mpos)
    -- add_tgt(mpos)
    color=6
  elseif (char=="P") then
    -- color=14
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

  if (player_tgt) then
    local coords=pos_to_screen_coords(player_tgt.pos)
    -- local c=same_position(player_tgt,pl) and 7 or 6
    -- player is draw over target
    rectdim(coords[1],coords[2],7,7,0,true)
    rectdim(coords[1],coords[2],7,7,6)
    palt(14,true)
    spr(pl.spr,coords[1],coords[2])
    palt()
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
      if (check_blocking(box)) then
        return -1
      else
        local res=push_boxes(box,dx,dy)
        if (res==-1) then
          local res_box=box_at_pos(box)
          if (res_box.sublevel) then
            enter_sublevel(res_box.sublevel,box,dx,dy)
          else
            revert_move(box)
            return -1
          end
        end
      end
      check_bounds(box,dx,dy)
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
  local maxx,maxy=sublevel.cols-1,sublevel.rows-1
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
  push_boxes(mvr,dx,dy)

  -- add(debug,tab_to_string(entr))
  if (mvr==pl) then
    -- add(debug,"hello?")
    mx,my=sublevel.x,sublevel.y
    mw,mh=sublevel.rows,sublevel.cols
  end

  check_blocking(pl)
end

function box_at_pos(mvr)
  for box in all(boxes) do
    if (box~=mvr and same_position(mvr,box)) then
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

function clear_map()
  for x=0,64 do
    for y=0,64 do
      mset(x,y,0)
    end
  end
end

function map_init()
  clear_map()
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
  elseif (char=="X") then
    add_tgt(mpos,true)
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
  if (sublevel) sublevel.box=nb
  add(boxes,nb)
end

function add_tgt(mpos,player)
  local pos=tab_dupe(mpos)
  pos.level=parsing_level
  local nt={
    pos=pos
  }
  if (player) then
    player_tgt=nt
  else
    add(tgts,nt)
  end
end

function check_bounds(mvr,dx,dy)
  local mpos=mvr.pos
  local mlevel=get_pos_level(mpos)
  
  local maxx,maxy=mlevel.cols-1,mlevel.rows-1
  local midx=mid(0,mpos.x,maxx)
  local midy=mid(0,mpos.y,maxy)

  if (midx==mpos.x and midy==mpos.y) return

  local lbox=mlevel.box
  mvr.pos=tab_dupe(lbox.pos)

  if (mpos.x<0) then
    mvr.pos.x-=1
  elseif (mpos.x>maxx) then
    mvr.pos.x+=1
  elseif (mpos.y<0) then
    mvr.pos.y-=1
  elseif (mpos.y>maxy) then
    mvr.pos.y+=1
  end

  push_boxes(mvr,dx,dy)
end

-- TODO: extract a lot of this position stuff to a new file
function get_pos_level(pos)
  local lkey=pos.level
  if (lkey=="main") then
    -- TODO: make sublevel and levels similar, either both map or not
    return level.map
  else
    return level.sublevels[lkey]
  end
end

function check_blocking(mvr)
  if (pos_blocked(mvr.pos)) then
    revert_move(mvr)
    return true
  end
end

function pos_blocked(pos)
  local tile=pos_tile(pos)
  return tile_blocking(tile)
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

  if (player_tgt) then
    if (not same_position(pl,player_tgt)) then
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
