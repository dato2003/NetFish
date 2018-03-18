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
local onError = function(event)
        print("Error: " .. event.error)
end

local Status


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
    --print(contents)
    io.close( file )
end
file = nil
return contents
end

local onError = function(event)
        print("Error: " .. event.error)
end

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
function Append(LocalName,RemoteName)
    DBconnection:append{
      remoteFile = "/MyProjects/SocialNet/".. RemoteName .. "",
      localFile = system.pathForFile(LocalName, system.TemporaryDirectory),
      onSuccess = onDownloadSuccess,
      onError = onError
    }
end


function UploadImages(event)
		if (event.phase == "began") then


        local function onComplete(event)
          if doesFileExist("photo.png") then
            id = "photo" .. math.random(1,10000) .. ".png"
            Upload("photo.png",id)
            WriteFile(id .. "\n","TMP.txt")
            K = "PhotoLogs" .. ReadFile("Current.txt") .. ".txt"
            Append("TMP.txt",K)
          end
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

function GetStatus(event)
  if ( event.phase == "ended" or event.phase == "submitted" ) then
    Status = event.target.text
    print(Status)
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

  local StatusT = display.newText( "Status:",display.contentCenterX,display.contentCenterY-150,native.systemFont,21 )
  StatusT:setFillColor( 0, 190/255 ,1)

  local StatusInput = native.newTextField(StatusT.x,StatusT.y+50,200,70)
  StatusInput:addEventListener("userInput",GetStatus)

  sceneGroup:insert(Background)
  sceneGroup:insert(ImageSelectBTN)
  sceneGroup:insert(BackBTN)
  sceneGroup:insert(StatusT)
  sceneGroup:insert(StatusInput)
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
    composer.removeScene( "Upload", false )
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
