-----------------------------------------------------------------------------------------
--
-- Home.lua
--
-----------------------------------------------------------------------------------------

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
--------------------------------------------
local onError = function(event)
        print("Error: " .. event.error)
end

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX


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


function ReadFile(File,K)
local path = system.pathForFile( File, system.TemporaryDirectory )
local file, errorString = io.open( path, "r" )
local contents = {}

if not file then
    print( "File error: " .. errorString )
else
  if K == 1 then
  for line in file:lines() do
      --print( line )
      if line ~= "\n" then
      contents[#contents+1] = line
      end
  end
  else
    contents = file:read( "*a" )
  end
  -- Close the file handle
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

function UploadStuff(event)
		if (event.phase == "began") then
      composer.gotoScene( "Upload","fade",500 )
		end
end

function Update()
  local PhotoLogs = "PhotoLogs" .. ReadFile("Current.txt",2) .. ".txt"
  --print(PhotoLogs)
  local list = ReadFile(PhotoLogs,1)
  local diff = MainView.height/2
  --print(#list)
  for i=1,#list do
    --print(#list)
    print(list[i])
    Download(list[i],list[i])
    Number = tonumber(string.match(list[i], "%d+"))
    print(Number)
    local id = "Status" .. Number .. ".txt"
    Download(id,id)
    local StatusText = ReadFile(id,2)


    local image = display.newImageRect(list[i],system.TemporaryDirectory, MainView.width - 50, MainView.height )
    image.x = MainView.width/2
    image.y = diff
    image.isVisible = true
    MainView:insert(image)

    local Status = display.newText( StatusText,image.x,diff + MainView.height/2 + 50,native.systemFont,21 )
    MainView:insert(Status)

    diff = diff + MainView.height + 100
  end
end

function Refresh(event)
  if event.phase == "began" then
    Download("PhotoLogs" .. ReadFile("Current.txt",2) .. ".txt","PhotoLogs" .. ReadFile("Current.txt",2) .. ".txt")
    Update()
  end
end

function Logout(event)
  if event.phase == "began" then
    composer.gotoScene( "menu","fade",500 )
  end
end
function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
	Background.x=display.contentCenterX
	Background.y=display.contentCenterY

	local UploadBTN = widget.newButton
	{
        label = "Upload",
        onEvent = UploadStuff,
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
	UploadBTN.x = display.contentCenterX-100
	UploadBTN.y = display.contentCenterY+230

  local BackBTN = widget.newButton
	{
        label = "Log out",
        onEvent = Logout,
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
	BackBTN.x = display.contentCenterX+100
	BackBTN.y = display.contentCenterY+230

  local RefreshBTN = widget.newButton
	{
        label = "Refresh",
        onEvent = Refresh,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "circle",
        radius = 35,
        fillColor = { default={0,0,1,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={0,0.4,1,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4
  }
	RefreshBTN.x = display.contentCenterX+100
  RefreshBTN.y = display.contentCenterY-230


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

  -------------------------------------- MAIN VIEW STUFF --------------------------------------


  -------------------------------------- MAIN VIEW STUFF --------------------------------------

	sceneGroup:insert(Background)
	sceneGroup:insert(UploadBTN)
	sceneGroup:insert(MainView)
  sceneGroup:insert(RefreshBTN)
  sceneGroup:insert(BackBTN)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
    Download("PhotoLogs" .. ReadFile("Current.txt",2) .. ".txt","PhotoLogs" .. ReadFile("Current.txt",2) .. ".txt")
    Update()
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
    composer.removeScene( "Home", false )
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
