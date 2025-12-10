function player_init(pos)
  pl={
    spr=1,
    xf=false,
    x=pos.x,
    y=pos.y,
  }
end

function player_update()
  pl_init_move()

  if (btnp(⬅️)) pl.dx=-1
  if (btnp(➡️)) pl.dx=1
  if (btnp(⬆️)) pl.dy=-1
  if (btnp(⬇️)) pl.dy=1

  if (pl_moving()) then
    pl_do_move()

    if (pl_out_of_bounds() or pl_hit_barrier()) revert_move(pl)
    push_boxes(pl,pl.dx,pl.dy)
    if (pl_on_box()) revert_move(pl)

    if (pl_has_moved()) record_undo()
  end
end

function pl_init_move()
  record_pos(pl)
  pl.dx,pl.dy=0,0
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

function pl_moving()
  return pl.dx~=0 or pl.dy~=0
end

function pl_has_moved()
  return pl.x~=pl.px or pl.y~=pl.py
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
  local xoff=pl.xf and -1 or 0
  spr(pl.spr,coords[1]+xoff,coords[2],1,1,pl.xf)
end
