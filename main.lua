function _init()
  state="game"
  states_init()
  handle_state()
end

function _update()
  init_debug()
  _upd()
end

function _draw()
  _drw()
  draw_debug()
end
