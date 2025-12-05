function init_debug()
  debug={}
end

function draw_debug()
  cursor(2,2,10)
  for d in all(debug) do
    print("\#0"..d)
  end
end

function map_to_screen_coords(x,y)
  return {x*8,y*8}
end

function rectdim(x,y,w,h,col)
  rect(x,y,x+w-1,y+h-1,col)
end
