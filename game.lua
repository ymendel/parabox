function game_init()
  mx=16
  my=0
  mw=9
  mh=9

  won=false
  tgts={}

  boxes_init()
  map_init()
  player_init()
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
  map(mx,my,0,0,9,9)
  boxes_draw()
  tgts_draw()
  player_draw()
  camera()
end

function boxes_init()
  boxes={}
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
      local tile=mget(box.x+mx,box.y+my)
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
  map(mx,my,0,0,mw,mh)
  local pals={
    {[1]=1,[12]=12},
    {[1]=8,[12]=14},
    {[1]=3,[12]=11},
    {[1]=2,[12]=8}
  }
  local pos_tgts={}
  for i=0,mw-1 do
    for j=0,mh-1 do
      local tile=mget(mx+i,my+j)
      if (tile_moveable(tile)) then
        local nb={
          spr=tile,
          pal=rnd(pals),
          x=i,
          y=j,
        }
        add(boxes,nb)
        mset(mx+i,my+j,17)
      end
      if (not(tile_moveable(tile) or tile_blocking(tile))) then
        add(pos_tgts, {x=i,y=j})
      end
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
