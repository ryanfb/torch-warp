require 'torch'
require 'nn'
require 'image'

local flowFile = require 'flowFileLoader'

local cmd = torch.CmdLine()

cmd:option('-flow_file', 'examples/example.flo', 'Target optical flow file')
cmd:option('-source_image', 'examples/example.png', 'Source image to warp')
cmd:option('-output_image', 'example_output.png', 'Destination warped image')
cmd:option('-scale', '0.5', 'Scale for optical flow, from 0-1')

local function main(params)
  local flow = flowFile.load(params.flow_file, params.scale)
  local imageWarped = warpImage(image.load(params.source_image, 3), flow)
  image.save(params.output_image, imageWarped)
end

-- warp a given image according to the given optical flow.
-- Disocclusions at the borders will be filled with the VGG mean pixel.
function warpImage(img, flow)
  local mean_pixel = torch.DoubleTensor({123.68/256.0, 116.779/256.0, 103.939/256.0})
  result = image.warp(img, flow, 'bilinear', true, 'pad', -1)
  for x=1, result:size(2) do
    for y=1, result:size(3) do
      if result[1][x][y] == -1 and result[2][x][y] == -1 and result[3][x][y] == -1 then
        result[1][x][y] = mean_pixel[1]
        result[2][x][y] = mean_pixel[2]
        result[3][x][y] = mean_pixel[3]
      end
    end
  end
  return result
end

local tmpParams = cmd:parse(arg)
local params = nil
local file = nil

if tmpParams.args == '' or file == nil  then
  params = cmd:parse(arg)
else
  local args = {}
  io.input(file)
  local argPos = 1
  while true do
    local line = io.read()
    if line == nil then break end
    if line:sub(0, 1) == '-' then
      local splits = str_split(line, " ", 2)
      args[argPos] = splits[1]
      args[argPos + 1] = splits[2]
      argPos = argPos + 2
    end
  end
  for i=1, #arg do
    args[argPos] = arg[i]
    argPos = argPos + 1
  end
  params = cmd:parse(args)
  io.close(file)
end

main(params)
