local component = require("component")
local event = require("event")
local io = require("io")

local edooriolib = {}

edooriolib.sides = {}

local function componentEvent(evtf, ctype)
  local comp
  while true do
    _, adr = event.pull(1, evtf)
    if component.type(adr) == ctype then
      comp = component.proxy(adr)
      break
    end
  end
  return comp
end

local function componentCycle(ctype, func, ...)
  local ctypes = component.list(ctype)
  local comp
  repeat
    print("Preparing to cycle through "..ctype.."\'s")
    require("os").sleep(3)
    for adr in pairs(ctypes) do
      component.proxy(adr)[func](...)
      io.write("Is this the correct "..ctype.."? [Y/n] ")
      if ((io.read() or "n").."y"):match("^%s*[Yy]") then
        comp = component.proxy(adr)
        break
      end
    end
  until comp
  return comp
end

function edooriolib.i_setup()
  require("term").clear()
  print("EDoorIO Setup:")
  local done = false
  local sides = 1
  local side = {}
  repeat
    print("Side "..sides)
    print("Plase activate the corisponding MagReader")
    side.magreader = componentEvent("magData", "os_magreader")
    print("Please active the corisponding KeyPad")
    side.keypad = componentEvent("keypad", "os_keypad")
    print("Type yes or no to find the corisponding Iron Noteblock")
    side.inoteblock = componentCycle("iron_noteblock","playNote",1)

    print("Side "..sides.." Is:")
    print("MagReader Address:      "..side.magreader.address)
    print("KeyPad Address:         "..side.keypad.address)
    print("Iron Noteblock Address: "..side.inoteblock.address)
    io.write("Is this correct? [Y/n] ")
    if ((io.read() or "n").."y"):match("^%s*[Yy]") then
      sides = sides + 1
      table.insert(edooriolib.sides, side)
      print("Sucessfully ineserted side")
    else
      print("Discarding side")
    end

    io.write("Do you want to add anothere side? [Y/n] ")
    if not ((io.read() or "n").."y"):match("^%s*[Yy]") then
      done = true
    else
      print("Continueing")
    end
  until done

  print(require("serialization").serialize(edooriolib.sides, true))
end

return edooriolib
