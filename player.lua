function player_init()
  pl={
    spr=1,
    xf=false,
    x=3,
    y=3,
  }
end

function player_update()
  local px,py=pl.x,pl.y

  pl_init_move()

  if (btnp(⬅️)) pl.dx=-1
  if (btnp(➡️)) pl.dx=1
  if (btnp(⬆️)) pl.dy=-1
  if (btnp(⬇️)) pl.dy=1

  pl_do_move()

  if (pl_out_of_bounds() or pl_hit_barrier()) pl.x,pl.y=px,py

  push_boxes()

  if (pl_on_box()) pl.x,pl.y=px,py
end

function pl_init_move()
  pl.dx=0
  pl.dy=0
end

function pl_do_move()
  if (pl.dx>0) then
    pl.xf=false
  elseif (pl.dx<0) then
    pl.xf=true
  end
  pl.x+=pl.dx
  pl.y+=pl.dy
end

function pl_out_of_bounds()
  local midx=mid(0,pl.x,15)
  local midy=mid(0,pl.y,15)

  if (midx~=pl.x or midy~=pl.y) return true

  return false
end

function pl_hit_barrier()
  local tile=mget(pl.x, pl.y)
  return tile_blocking(tile)
end

function player_draw()
  local coords=map_to_screen_coords(pl.x,pl.y)
  spr(pl.spr,coords[1],coords[2],1,1,pl.xf)
end
