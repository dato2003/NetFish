local composer = require( "composer" )
local scene = composer.newScene()

local widget = require ( "widget" )
local sqlite3 = require( "sqlite3" )

local ftp = require ( "ftp" )
local DBconnection = ftp.newConnection{
        host = "files.000webhost.com",
        user = "sleepydevs",
        password = "dato2003",
        port = 21 -- Optional. Will default to 21.
}
--------------------------------------------------------------------------------
function Upload(LocalName,RemoteName)
    DBconnection:upload{
      localFile = system.pathForFile(LocalName, system.TemporaryDirectory),
      remoteFile =  "/MyProjects/SocialNet/".. RemoteName .. "",
      onSuccess = onUploadSuccess,
      onError = onError
    }
    print("Uploaded to Path : /MyProjects/SocialNet/".. RemoteName .. "")
end
function Download(LocalName,RemoteName)
    DBconnection:download{
      remoteFile = "/MyProjects/SocialNet/".. RemoteName .. "",
      localFile = LocalName,
      onSuccess = onDownloadSuccess,
      onError = onError
    }
end

function UploadImages(event)
		if (event.phase == "began") then

        local function onComplete(event)
            id = "photo" .. math.random(1,10000) .. ".png"
            Upload("photo.png",id)
        end

        if media.hasSource( media.PhotoLibrary ) then
            media.selectPhoto(
                {
                 mediaSource=media.PhotoLibrary,
                 destination = { baseDir=system.TemporaryDirectory, filename="photo.png" },
                 listener = onComplete,
                }
            )
        else
          native.showAlert( "Corona", "This device does not have a photo library.", { "OK" } )
        end


    end
end

function Back(event)
  if event.phase == "began" then
    composer.gotoScene( "Home","fade",500 )
  end
end



function scene:create( event )
  local sceneGroup = self.view

  -- Initialize the scene here.
  -- Example: add display objects to "sceneGroup", add touch listeners, etc.

  local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
	Background.x=display.contentCenterX
	Background.y=display.contentCenterY

  local ImageSelectBTN = widget.newButton
	{
        label = "Upload Image",
        onEvent = UploadImages,
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
	ImageSelectBTN.x = display.contentCenterX
	ImageSelectBTN.y = display.contentCenterY-200

  local BackBTN = widget.newButton
	{
        label = "Back",
        onEvent = Back,
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
	BackBTN.x = display.contentCenterX
	BackBTN.y = display.contentCenterY+200

  sceneGroup:insert(Background)
  sceneGroup:insert(ImageSelectBTN)
  sceneGroup:insert(BackBTN)
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

--------------------------------------------------------------------------------
-- "scene:hide()"
--------------------------------------------------------------------------------
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
