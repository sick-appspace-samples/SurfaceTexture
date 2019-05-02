--[[----------------------------------------------------------------------------

  Application Name:
  SurfaceTexture

  Summary:
  Finding upside down cookies.

  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the
  'main' function allows debugging step-by-step.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show images after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.

  More Information:
  Tutorial "Algorithms - Blob Analysis".

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 500

-- Creating viewer
local viewer = View.create()
viewer:setID('viewer2D')

-- Setting up graphical overlay attributes
local decoNeutral = View.ShapeDecoration.create()
decoNeutral:setFillColor(230, 230, 0, 80) -- Transparent yellow

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
  local imageID = viewer:addImage(img)
  local failedCookies = 0

  -- For each cookie, estimate the orientation based on texture statistics
  for i = 1, #cookieObjects do
    local _, _, _, stddev = cookieObjects[i]:getStatistics(edgeImg)
    if stddev > 40 then
      viewer:addPixelRegion(cookieObjects[i], decoFail, nil, imageID)
      failedCookies = failedCookies + 1
    else
      viewer:addPixelRegion(cookieObjects[i], decoPass, nil, imageID)
    end
    viewer:present() -- presenting single steps
    Script.sleep(DELAY) -- for demonstration purpose only
  end
  print('Cookies upside down: ' .. failedCookies)
  print('App finished.')
end

Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
