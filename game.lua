function game_init()
  player_init()
end

function game_update()
  player_update()
end

function game_draw()
  cls()
  map()
  player_draw()
end
