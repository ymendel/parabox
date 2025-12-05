function game_init()
  boxes_init()
  map_init()
  player_init()
end

function game_update()
  player_update()
end

function game_draw()
  cls()
  camera(-30,-30)
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
      else
        push_boxes(box,dx,dy)
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
  for i=0,15 do
    for j=0,15 do
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
    end
  end
end

function tile_blocking(tile)
  return fget(tile,1)
end

function tile_moveable(tile)
  return fget(tile,2)
end
