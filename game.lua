function game_init()
  lnum=lnum or 1
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
  camera(-64+mw*4,-64+mh*4)
  level_draw()
  boxes_draw()
  tgts_draw()
  player_draw()
  camera()
end

function level_draw()
  map(0,0,0,0,mw,mh)
  -- rect(-2,-2,mw*8,mh*8,7)
end

function boxes_draw()
  for box in all(boxes) do
    local coords=pos_to_screen_coords(box.pos)
    -- pal(box.pal)
    -- spr(box.spr,coords[1],coords[2])
    rectdim(coords[1],coords[2],7,7,12,true)
  end
  -- pal()
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
  for box in all(boxes) do
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

function pl_on_box()
  for box in all(boxes) do
    if (same_position(pl,box)) then
      return true
    end
  end
  return false
end

function map_init()
  -- local pals={
  --  {[1]=1,[12]=12},
  --  {[1]=8,[12]=14},
  --  {[1]=3,[12]=11},
  --  {[1]=2,[12]=8}
  -- }

  for j=1,level.rows do
    local line=level.lines[j]
    -- printh(line,"blah")
    for i=1,level.cols do
      local char=sub(line,i,i)
      -- printh(char,"blah")

      local mx,my=i-1,j-1
      local mpos={x=mx,y=my}
      local tile=17

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
      end

      mset(mx,my,tile)
    end
  end
end

function add_box(mpos)
  local nb={
    spr=2,
    pos=tab_dupe(mpos)
  }
  add(boxes,nb)
end

function add_tgt(mpos)
  local nt={
    pos=tab_dupe(mpos)
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
