function game_init()
  boxes_init()
  map_init()
  player_init()
  won=false
end

function game_update()
  if (won) then
    state="win"
    handle_state()
    return
  end
  player_update()
  check_boxes()
end

function game_draw()
  cls()
  camera(-20,-20)
  map()
  boxes_draw()
  player_draw()
  camera()
end

function boxes_init()
  boxes={}
end

function boxes_draw()
  for box in all(boxes) do
    local coords=map_to_screen_coords(box.x,box.y)
    spr(box.spr,coords[1],coords[2])
    if (box.tgt and box.tgt_col) then
      local tgt_coords=map_to_screen_coords(box.tgt[1],box.tgt[2])
      rectdim(tgt_coords[1],tgt_coords[2],7,7,box.tgt_col)
    end
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
  map()
  local tgts={}
  for i=0,10 do
    for j=0,10 do
      local tile=mget(i,j)
      if (tile_moveable(tile)) then
        local nb={
          spr=tile,
          x=i,
          y=j,
        }
        add(boxes,nb)
        mset(i,j,17)
      end
      if (not(tile_moveable(tile) or tile_blocking(tile))) then
        add(tgts, {i,j})
      end
    end
  end

  for box in all(boxes) do
    local tgt=rnd(tgts)
    box.tgt=tgt
    box.tgt_col=tgt_col(box.spr)
    del(tgts,tgt)
  end
end

function tgt_col(tile)
  local sx,sy=tile%16,tile\16
  return sget(sx*8+4,sy*8+4)
end

function tile_blocking(tile)
  return fget(tile,1)
end

function tile_moveable(tile)
  return fget(tile,2)
end

function check_boxes()
  for box in all(boxes) do
    if (not box_on_target(box)) then
      return false
    end
  end

  won=true
end

function box_on_target(box)
  if (not box.tgt) return false
  return box.x==box.tgt[1] and box.y==box.tgt[2]
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
