function player_init(mpos)
  local pos=tab_dupe(mpos)
  pos.level="main"
  pl={
    spr=1,
    xf=false,
    pos=pos,
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
    handle_box_push()
    local pl_box=pl_on_box()
    if (pl_box) then
      if (pl_box.sublevel) then
        enter_sublevel(pl_box.sublevel,pl,pl.dx,pl.dy)
      else
        revert_move(pl)
      end
    end

    if (has_moved(pl)) record_undo()
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

  move(pl,pl.dx,pl.dy)
end

function pl_moving()
  return pl.dx~=0 or pl.dy~=0
end

-- do I still need this? the levels will be enclosed? always?
-- Also, if I need it I need to get info from the level, not just use 15
function pl_out_of_bounds()
  local midx=mid(0,pl.pos.x,15)
  local midy=mid(0,pl.pos.y,15)

  if (midx~=pl.pos.x or midy~=pl.pos.y) return true

  return false
end

function pl_hit_barrier()
  local tile=pos_tile(pl.pos)
  return tile_blocking(tile)
end

function player_draw()
  local coords=pos_to_screen_coords(pl.pos)
  local xoff=pl.xf and -1 or 0
  spr(pl.spr,coords[1]+xoff,coords[2],1,1,pl.xf)
end
