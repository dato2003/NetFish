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
local me = ReadFile("CurrentDude.txt")
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local textout = PubnubUtil.textout
local diff = 0

chat = pubnub.new({
    publish_key   = "pub-c-6a5d691f-c294-4ac1-89d9-931d19888100",
    subscribe_key = "sub-c-d34f9db2-39a0-11e8-afae-2a65d00afee8",
    secret_key    = "sec-c-ZmU2ZTc2MDYtYzUwNS00ZWRlLWE1YTgtNjA0ODdkNzMxYTZh",
    ssl           = true,
    origin        = "pubsub.pubnub.com"
})

function listener(event)
  if (event.phase == "began") then
    native.setKeyboardFocus( chatbox )
    event.target.y = display.contentCenterY+80
  end
  if not (event.phase == "ended" or event.phase == "submitted") then
      return
  end

  -- Don't send Empyt Message
  --if chatbox.text == '' then  event.target.y = display.contentCenterY+200 return end
  local msg = me .. ":" .. chatbox.text
  send_a_message(tostring(msg))
  chatbox.text = ''
  native.setKeyboardFocus(nil)
  event.target.y = display.contentCenterY+200
end

CHAT_CHANNEL = ReadFile("Current.txt")

function connect()
    chat:subscribe({
        channel  = CHAT_CHANNEL,
        connect  = function()
          local Status = display.newText("Connected!", MainView.width/2 , 0 , Font , 20)
          Status:setFillColor(123/255,128/255,255/255)
          MainView:insert(Status)

          diff = diff + 30
            --textout('Connected!')
        end,
        callback = function(message)
          ---------------------------------------------------------------------
          local x = 19
          if string.len( message.msgtext ) > 40 then
            x = 17
            print(string.len( message.msgtext ))
          end
          local Status = display.newText(message.msgtext, MainView.width/2 , diff , MainView.width - 20 , 0 , Font , x,"left")
          Status:setFillColor(123/255,128/255,255/255)
          MainView:insert(Status)

          diff = diff + 35
          print(diff .. " " .. MainView.height)

          local function onScrollComplete()
              print( "Scroll complete!" )
          end
          if diff >= MainView.height then
            MainView:scrollTo("bottom",{onComplete = onScrollComplete})
          end
          ---------------------------------------------------------------------
        end,
        error = function(message)
          local Status = display.newText(message.msgtext, MainView.width/2 , diff , Font , 20)
          Status:setFillColor(123/255,128/255,255/255)
          MainView:insert(Status)

          diff = diff + 30
            --textout(message or "Connection Error")
        end
    })
end

--
-- A FUNCTION THAT WILL CLOSE NETWORK A CONNECTION TO PUBNUB
--
function disconnect()
    chat:unsubscribe({
        channel = CHAT_CHANNEL
    })
    --textout('Disconnected!')
end

--
-- A FUNCTION THAT WILL SEND A MESSAGE
--
function send_a_message(text)
    if text ~= me .. ":" then
    chat:publish({
        channel  = CHAT_CHANNEL,
        message  = { msgtext = text },
        callback = function(info)
        end
    })
  end
end


function onKeyEvent( event )

    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        if ( system.getInfo("platform") == "androd" or system.getInfo("platform") == "ios") then
            chatbox.text = ''
            chatbox.y = display.contentCenterY+200
            native.setKeyboardFocus( nil )
            return true
        end
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    --return false
end

function BackFunc(event)
  if (event.phase == "ended") then
    composer.gotoScene( "Navigator","fade",500 )
  end
end

function scene:create( event )
  local sceneGroup = self.view

  -- Initialize the scene here.
  -- Example: add display objects to "sceneGroup", add touch listeners, etc.
  local Background = display.newRect( display.contentCenterX, display.contentCenterY,
   display.actualContentWidth, display.actualContentHeight )
  Background:setFillColor(107/255,111/255,112/255)


  chatbox = native.newTextField( display.contentCenterX, display.contentCenterY+200, display.actualContentWidth - 20, 36)
  chatbox:addEventListener("userInput",listener)

  Back = widget.newButton
  {
    label = "Back",
    onEvent = BackFunc,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 200,
    height = 40,
    cornerRadius = 2,
    fillColor = { default={0,0,1,1}, over={1,0.1,0.7,0.4} },
    strokeColor = { default={0,0.4,1,1}, over={0.8,0.8,1,1} },
    strokeWidth = 4
  }
  Back.x = display.contentCenterX
  Back.y = display.contentCenterY+250

  MainView = widget.newScrollView
  {
    x = screenW*0.5,
    y = screenH*0.5,
    width = screenW*0.9,
    height = screenH*0.7,
    topPadding = 20,
    backgroundColor = { 0.8, 0.8, 0.8 },
    horizontalScrollDisabled = true,
    listener = scrollListener
  }
  MainView.x = display.contentCenterX
  MainView.y = display.contentCenterY-30


  sceneGroup:insert(Background)
  sceneGroup:insert(chatbox)
  sceneGroup:insert(Back)
  sceneGroup:insert(MainView)
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
    connect()
  end
end


function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Called when the scene is on screen (but is about to go off screen).
    -- Insert code here to "pause" the scene.
    -- Example: stop timers, stop animation, stop audio, etc.
    disconnect()
  elseif ( phase == "did" ) then
    -- Called immediately after scene goes off screen.
    composer.removeScene( "Chat", false )
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
-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )


return scene
