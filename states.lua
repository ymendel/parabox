function states_init()
  states={
    game={
      init=game_init,
      update=game_update,
      draw=game_draw,
    },
  }
end

function handle_state()
  stif=states[state]
  if (not stif) return

  stif["init"]()
  _upd=stif["update"]
  _drw=stif["draw"]
end
