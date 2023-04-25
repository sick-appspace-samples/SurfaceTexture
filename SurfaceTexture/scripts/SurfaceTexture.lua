
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 500

-- Creating viewer
local viewer = View.create()

-- Setting up graphical overlay attributes
local decoPass = View.PixelRegionDecoration.create()
decoPass:setColor(0, 230, 0, 80) -- Transparent green

local decoFail = View.PixelRegionDecoration.create()
decoFail:setColor(230, 0, 0, 80) -- Transparent red

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-- Loading and viewing image
local function main()
  viewer:clear()
  local img = Image.load('resources/SurfaceTexture.bmp')
  viewer:addImage(img)
  viewer:present()
  Script.sleep(DELAY * 2)

  -- Finding cookies (blobs) using morphology/closing to remove holes
  local cookieRegion = img:threshold(0, 120)
  cookieRegion = cookieRegion:dilate(5)
  cookieRegion = cookieRegion:erode(21)

  local cookieObjects = cookieRegion:findConnected(500)
  print('Cookies found: ' .. #cookieObjects)

  -- Retrieving edge magnitude of image to extract texture
  local edgeImg = img:sobelMagnitude()
  viewer:clear()
  viewer:addImage(edgeImg)
  viewer:present()
  Script.sleep(DELAY * 2) -- for demonstration purpose only

  viewer:clear()
  viewer:addImage(img)
  local failedCookies = 0
  -- For each cookie, estimate the orientation based on texture statistics
  local _, _, _, stddevs = cookieObjects:getStatistics(edgeImg)
  for i = 1, #stddevs do
    if stddevs[i] > 40 then
      viewer:addPixelRegion(cookieObjects[i], decoFail)
      failedCookies = failedCookies + 1
    else
      viewer:addPixelRegion(cookieObjects[i], decoPass)
    end
    viewer:present() -- presenting single steps
    Script.sleep(DELAY) -- for demonstration purpose only
  end
  print('Cookies upside down: ' .. failedCookies)
  print('App finished.')
end

--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
