
-- Globals.lua
-- All globals in the entire project must be assigned in this file

--
lg = love.graphics
-- a suite of functions for keyboard input
lk = love.keyboard
-- a suite of functions for mouse input
lm = love.mouse
-- a suite of functions for playing audio
la = love.audio
-- a suite of functions for dealing with the file system
lf = love.filesystem
-- a suite of functions for working with images
li = love.image
-- a suite of functions for working with sounds
ls = love.sound
-- a suite of functions for working with threads
lt = love.thread
--a suite of functions for physics simulation
lp = love.physics

KeyConstant = {
  a = 'a',
  b = 'b',
  c = 'c',
  d = 'd',
  e = 'e',
  f = 'f',
  g = 'g',
  h = 'h',
  i = 'i',
  j = 'j',
  k = 'k',
  l = 'l',
  m = 'm',
  n = 'n',
  o = 'o',
  p = 'p',
  q = 'q',
  r = 'r',
  s = 's', 
  t = 't',
  u = 'u',
  v = 'v',
  w = 'w',
  x = 'x',
  y = 'y',
  z = 'z',
  zero = '0',
  one = '1',
  two = '2',
  three = '3',
  four = '4',
  five = '5',
  six = '6',
  seven = '7',
  eight = '8',
  nine = '9',
  space = ' ',
  exclamation = '!',
  doube_quote = '\"',
  hash = '#',
  dollar = '$',
  ampersand = '&',
  single_quote = '\'',
  left_paren = '(',
  right_paren = ')',
  asteriks = '*',
  plus = '+',
  comma = ',',
  hyphen = '-',
  period = '.',
  slash = '/',
  colon = ':',
  semicolon = ';',
  less_than = '<',
  question = '?',
  at_sign = '@',
  left_square_bracket = '[',
  backslash = '\\',
  right_square_bracket = ']',
  caret = '^',
  underscore = '_',
  grave_accent = '`',
  
  --numpad zero
  kp0 = 'kp0',
  --numpad one
  kp1 = 'kp1',
  --numpad two
  kp2 = 'kp2',
  --numpad three
  kp3 = 'kp3',
  --numpad four
  kp4 = 'kp4',
  --numpad five
  kp5 = 'kp5',
  --numpad six
  kp6 = 'kp6',
  --numpad seven
  kp7 = 'kp7',
  --numpad eight
  kp8 = 'kp8',
  --numpad nine
  kp9 = 'kp9',  
  
  --numpad decimal point
  kp_dec_point = 'kp.',
  
  --numpad division
  kp_div = 'kp/',
  
  --numpad multiplication
  kp_mult = 'kp*',
  
  --numpad subtraction
  kp_sub = 'kp-',
  
  --numpad addition
  kp_add = 'kp+',
  
  --numpad enter key
  kp_enter = 'kpenter',
  
  --numpad equals key
  kp_equals = 'kp=',
  
  --up cursor key
  up = 'up',
  
  --down cursor key
  down = 'down',
  
  --left cursor key
  left = 'left',
  
  --right cursor key,
  right = 'right',
  
  --home key
  home = 'home',
  
  --end key
  end_key = 'end',
  
  --page up key
  pageup = 'pageup',
  
  --page down key
  pagedown = 'pagedown',
  
  insert = 'insert',
  
  backspace = 'backspace',
  
  tab = 'tab',
  
  clear = 'clear',
  
  return_key = 'return',
  
  delete = 'delete',
  
  f1 = 'f1',
  f2 = 'f2',
  f3 = 'f3',
  f4 = 'f4',
  f5 = 'f5',
  f6 = 'f6',
  f7 = 'f7',
  f8 = 'f8',
  f9 = 'f9',
  f10 = 'f10',
  f11 = 'f11',
  f12 = 'f12',
  f13 = 'f13',
  f14 = 'f14',
  f15 = 'f15',
  
  numlock = 'numlock',
  capslock = 'capslock',
  scrollock = 'scrollock',
  rshift = 'rshift',
  lshift = 'lshift',
  rctrl = 'rctrl',
  lctrl = 'lctrl',
  ralt = 'ralt',
  lalt = 'lalt',
  rmeta = 'rmeta',
  lmeta = 'lmeta',
  lsuper = 'lsuper',
  rsuper = 'rsuper',
  mode = 'mode',
  compose = 'compose',
  
  pause = 'pause',
  escape = 'escape',
  help = 'help',
  print = 'print',
  sysreq = 'sysreq',
  brk = 'break',
}

BlendMode = {
  additive = 'additive',
  alpha = 'alpha',
  subtractive = 'subtractive',
  multiplicative = 'multiplicative',
  premultiplied = 'premultiplied',
}

DistanceModel = {
  none = 'none',
  inverse = 'inverse',
  inverse_clamped = 'inverse clamped',
  linear = 'linear',
  linear_clamped = 'linear_clamped',
  exponential = 'exponent',
  exponential_clamped = 'exponent_clamped'
}

Event = {
  focus = 'focus',
  joystickpressed = 'joystickpressed',
  joystickreleased = 'joystickreleased',
  keypressed = 'keypressed',
  keyreleased = 'keyreleased',
  mousepressed = 'mousepressed',
  mousereleased = 'mousereleased',
  quit = 'quit'
}

FileDecoder = {
  default = 'file',
  file = 'file',
  base64 = 'base64'
}

FileMode = {
  read = 'r',
  write = 'w',
  append = 'a'
}

FilterMode = {
  --linear interpolation
  linear = 'linear',
  --nearest neighbor interpolation
  nearest = 'nearest',
}

GraphicsFeature = {
  canvas = 'canvas',
  pixeleffect = 'pixeleffect',
  --non-power-of-two textures
  npot = 'npot',
  subtractive = 'subtractive'  
}

ImageFormat = {
  bmp = 'bmp',
  tga = 'tga',
  png = 'png',
  jpg = 'jpg',
  gif = 'gif'
}

JointType = {
  distance = 'distance',
  gear = 'gear',
  mouse = 'mouse',
  prismatic = 'prismatic',
  pulley = 'pulley',
  revolute = 'revolute',
}

JoystickConstant = {
  centered = 'c',
  down = 'd',
  left = 'l',
  left_down = 'ld',
  left_up = 'lu',
  right = 'r',
  right_down = 'rd',
  right_up = 'ru',
  up = 'u'
}

LineStyle = {
  rough = 'rough',
  smooth = 'smooth'
}

MouseConstant = {
  left_button = 'l',
  middle_button = 'm',
  right_button = 'r',
  wheel_down = 'wd',
  wheel_up = 'wu',
  x1 = 'x1',
  x2 = 'x2'
}
