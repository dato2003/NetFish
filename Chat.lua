local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require( "widget" )
local sqlite3 = require( "sqlite3" )

local ftp = require ( "ftp" )
local DBconnection = ftp.newConnection{
        host = "files.000webhost.com",
        user = "sleepydevs",
        password = "dato2003",
        port = 21 -- Optional. Will default to 21.
}

math.randomseed( os.time() )
require "pubnub"
require "PubnubUtil"

--------------------------------------------------------------------------------
function doesFileExist( fname)
    local results = false
    local filePath = system.pathForFile( fname, system.TemporaryDirectory )
    if ( filePath ) then
        local file, errorString = io.open( filePath, "r" )
        if not file then
            print( "File error: " .. errorString )
        else
            print( "File found: " .. fname )
            results = true
            file:close()
        end
    end
    return results
end


function WriteFile(saveData,File)
local path = system.pathForFile( File, system.TemporaryDirectory )
local file, errorString = io.open( path, "w" )

if not file then
    print( "File error: " .. errorString )
else
    file:write( saveData )
    io.close( file )
end
file = nil
end


function ReadFile(File)
local path = system.pathForFile( File, system.TemporaryDirectory )
local file, errorString = io.open( path, "r" )
local contents

if not file then
    print( "File error: " .. errorString )
else
    contents = file:read( "*a" )
    io.close( file )
end
file = nil
return contents
end

local Font = native.newFont( "Marlboro.ttf" , 35 )


local textout = PubnubUtil.textout

chat = pubnub.new({
    publish_key   = "pub-c-6a5d691f-c294-4ac1-89d9-931d19888100",
    subscribe_key = "sub-c-d34f9db2-39a0-11e8-afae-2a65d00afee8",
    secret_key    = "sec-c-ZmU2ZTc2MDYtYzUwNS00ZWRlLWE1YTgtNjA0ODdkNzMxYTZh",
    ssl           = nil,
    origin        = "pubsub.pubnub.com"
})

function listener(event)
  if not (event.phase == "ended" or event.phase == "submitted") then
      return
  end

  -- Don't send Empyt Message
  if chatbox.text == '' then return end

  send_a_message(tostring(chatbox.text))
  chatbox.text = ''
  native.setKeyboardFocus(nil)
end

CHAT_CHANNEL = ReadFile("Current.txt")
print(CHAT_CHANNEL)

function scene:create( event )
  local sceneGroup = self.view

  -- Initialize the scene here.
  -- Example: add display objects to "sceneGroup", add touch listeners, etc.

  local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
	Background.x=display.contentCenterX
	Background.y=display.contentCenterY

  chatbox = native.newTextField( display.contentCenterX, display.contentCenterY+200, display.actualContentWidth - 20, 36)
  chatbox:addEventListener("userInput",listener)


  sceneGroup:insert(Background)
  sceneGroup:insert(chatbox)
end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Called when the scene is still off screen (but is about to come on screen).
  elseif ( phase == "did" ) then
    -- Called when the scene is now on screen.
    -- Insert code here to make the scene come alive.
    -- Example: start timers, begin animation, play audio, etc.
  end
end


function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Called when the scene is on screen (but is about to go off screen).
    -- Insert code here to "pause" the scene.
    -- Example: stop timers, stop animation, stop audio, etc.
  elseif ( phase == "did" ) then
    -- Called immediately after scene goes off screen.
  end
end

--------------------------------------------------------------------------------
-- "scene:destroy()"
--------------------------------------------------------------------------------
function scene:destroy( event )
  local sceneGroup = self.view

  -- Called prior to the removal of scene's view ("sceneGroup").
  -- Insert code here to clean up the scene.
  -- Example: remove display objects, save state, etc.
end

--------------------------------------------------------------------------------
-- Listener setup
--------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--------------------------------------------------------------------------------

return scene
