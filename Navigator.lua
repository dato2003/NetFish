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
--------------------------------------------------------------------------------
local Font = native.newFont( "Marlboro.ttf" , 35 )


function Posts(event)
  if (event.phase == "ended") then
    composer.gotoScene( "Home","fade",500 )
  end
end

function Logoutfunc(event)
  if (event.phase == "ended") then
    composer.gotoScene( "menu","fade",500 )
  end
end

function ChatFunc(event)
  if (event.phase == "ended") then
    composer.gotoScene( "Chat","fade",500 )
  end
end

function scene:create( event )
  local sceneGroup = self.view

  -- Initialize the scene here.
  -- Example: add display objects to "sceneGroup", add touch listeners, etc.

  local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
	Background.x=display.contentCenterX
	Background.y=display.contentCenterY


  local LogoScreen = display.newText("Home Screen",display.contentCenterX,display.contentCenterY-250,Font,40)
	LogoScreen:setFillColor( 0, 190/255, 1 )

  local PostsPage = widget.newButton
	{
    label = "Posts",
    onEvent = Posts,
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
	PostsPage.x = display.contentCenterX
	PostsPage.y = display.contentCenterY-100



  local Logout = widget.newButton
  {
    label = "Log out",
    onEvent = Logoutfunc,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 100,
    height = 40,
    cornerRadius = 2,
    fillColor = { default={0,0,1,1}, over={1,0.1,0.7,0.4} },
    strokeColor = { default={0,0.4,1,1}, over={0.8,0.8,1,1} },
    strokeWidth = 4
  }
  Logout.x = display.contentCenterX+75
  Logout.y = display.contentCenterY+200

  local Chat = widget.newButton
  {
    label = "Chat",
    onEvent = ChatFunc,
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
  Chat.x = display.contentCenterX
  Chat.y = display.contentCenterY-50

  sceneGroup:insert(Background)
  sceneGroup:insert(LogoScreen)
  sceneGroup:insert(PostsPage)
  sceneGroup:insert(Logout)
  sceneGroup:insert(Chat)
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
    composer.removeScene( "Navigator", false )
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
