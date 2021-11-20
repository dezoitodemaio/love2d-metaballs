local g = love.graphics

local w, h = g.getWidth(), g.getHeight()

local ballss = {}

local fac = 0

local count = 0

function love.load()

  myShader = love.graphics.newShader[[
    uniform vec3 balls[20];
    uniform float fac;

    vec3 hsv(float h,float s,float v) { return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v; }

    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 sc ){

      float c = 0;

      for(int i = 0; i < balls.length(); i++){
        vec3 b = balls[i];

        vec2 p1 = vec2(b[0], b[1]);

        float d = distance(p1, sc);

        float x = b[2]  / (d * fac);

        c = c + x;
      }

      if(c > 1.5)
        c = 1.5;

      return vec4(hsv(c,c,c), 1);
    }
  ]]

  g.setShader(myShader)  
  
  for i = 1, 15 do
    local b = {}
    local r = math.rad(math.random()*360)
    local s = math.random(2, 4)
    b.vx = math.sin(r) * s
    b.vy = math.cos(r) * s
    b.x = w/2
    b.y = h/2
    b.s = math.random(350, 500)
    table.insert(ballss, b)
  end
  
end

function send()
  local send = {}
  for k, b in pairs(ballss) do
    send[k] = {b.x, b.y, b.s}
  end
  myShader:send("balls", unpack(send))  
  myShader:send("fac", fac)  
end

function love.update(dt)
  if not pause then
    for k, b in pairs(ballss) do
      
      b.x = b.x + b.vx
      b.y = b.y + b.vy
  
      if b.x < 0 or b.x > w then
        b.vx = b.vx * -1
      end
      if b.y < 0 or b.y > h then
        b.vy = b.vy * -1
      end
    end
  end

  send()
end


function love.draw()
  g.rectangle("fill", 0, 0, w, h)  
end

function love.mousemoved( x, y, dx, dy, istouch )
	fac = y / h * 50
end

function love.mousepressed(x, y, button, istouch)
  pause = not pause
end