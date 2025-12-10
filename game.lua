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

    debug_output_undo()
  end
end

function do_undo(u)
  if (u) then
    pl.x,pl.y=u.pl.x,u.pl.y
    for i,box in ipairs(boxes) do
      local ubox=u.boxes[i]
      box.x,box.y=ubox.x,ubox.y
      box.px,box.py=ubox.x,ubox.y
    end
  end
end

function record_undo()
  local box_info={}
  for i,box in ipairs(boxes) do
    box_info[i]={x=box.px,y=box.py}
  end

  local nu={
    pl={x=pl.px,y=pl.py},
    boxes=box_info,
  }
  add(undo_stack,nu)

  debug_output_undo()
end

function debug_output_undo()
  local filename="undo"
  printh("undo stack:",filename,true)
  for n,u in ipairs(undo_stack) do
    printh("-------\nent - "..n.."\n",filename)
    printh("pl - "..u.pl.x..","..u.pl.y,filename)
    for i,box in ipairs(u.boxes) do
      local boxx=box.x or "nil"
      local boxy=box.y or "nil"
      printh("box "..i.." - "..boxx..","..boxy,filename)
    end
    printh("-------\n",filename)
  end
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
    local coords=map_to_screen_coords(box.x,box.y)
    -- pal(box.pal)
    spr(box.spr,coords[1],coords[2])
  end
  -- pal()
end

function tgts_draw()
  for tgt in all(tgts) do
    local coords=map_to_screen_coords(tgt.x,tgt.y)
    rectdim(coords[1],coords[2],7,7,7)
  end
end

function push_boxes(pusher,dx,dy)
  for box in all(boxes) do
    if (pusher~=box and same_position(pusher,box)) then
      record_pos(box)
      box.x+=dx
      box.y+=dy
      local tile=mget(box.x,box.y)
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

function record_pos(mvr)
  mvr.px,mvr.py=mvr.x,mvr.y
end

function revert_move(mvr)
  mvr.x,mvr.y=mvr.px,mvr.py
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

function add_box(pos)
  local nb={
    spr=2,
    x=pos.x,
    y=pos.y,
  }
  record_pos(nb)
  add(boxes,nb)
end

function add_tgt(pos)
  add(tgts,pos)
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
