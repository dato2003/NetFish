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
--------------------------------------------
local onError = function(event)
  print("Error: " .. event.error)
  local alert = native.showAlert( "NetFish", "Error: " .. event.error , { "OK" })
end

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

local path = system.pathForFile( "UserDB.db", system.TemporaryDirectory )
local db = sqlite3.open( path )

local Font = native.newFont( "Marlboro.ttf" , 35 )
local OldPass
local NewPass

function loadData()
    local sql = "select * from UserDB"
    local people = {}

    for row in db:nrows(sql) do
        people[#people+1] =
        {
          FirstName = row.Username,
    			LastName = row.Password,
					Email = row.Email,
					Certified = row.Certified,
          House = row.House
        }
    end

    return people
end

function insertData(Username, Password, House, Email, Certified)
    local sql = [[INSERT into UserDB (UserID, Username, Password, House, Email, Certified) values
		(NUll,']] .. Username .. [[',']] .. Password .. [[',']] .. House .. [[',']] .. Email .. [[',']] .. Certified .. [[')]]
    db:exec(sql)
end

function deleteData(id)
    local sql = [[DELETE from UserDB where UserID =']] .. id .. [['']]
    db:exec(sql)
end

function updateData(id, Clue, Info1, Info2)
    local sql = [[UPDATE UserDB set ]].. Info1 .. [[ = ']] .. Info2 .. [[' where ]] .. Clue .. [[ = ']] .. id .. [[']]
    db:exec(sql)
end


function Pass1func(event)
  if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		OldPass = event.target.text
		--print(Username)
	end
end

function Pass2func(event)
  if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		NewPass = event.target.text
		--print(Username)
	end
end

function UpdatePas(event)
	if(event.phase == "began") then
    --print("logging")
		if (OldPass ~= nil and NewPass ~= nil) then
      --print("logging")
			local Correct = false
			local people=loadData()
			for i=1,#people do
				print("Username:" .. people[i].FirstName .. "\nPassword:" .. people[i].LastName ..
				"\nEmail:" .. people[i].Email .. "\nCertified:" .. people[i].Certified ..
        "\nHouse:" .. people[i].House .. "\n\n\n")
				if (people[i].FirstName == ReadFile("CurrentDude.txt") and people[i].LastName == OldPass) then
					--print("loggingssadasda")
          updateData(people[i].FirstName,"Username","Password",NewPass)
					Correct=true
          composer.gotoScene( "Navigator","fade",500 )
				end
			end
			if (Correct==false) then
			local alert = native.showAlert( "Incorrect Old Password or Unfilled Fields","Please Enter Correct Password and Fill everything",{"OK"})
			end
		end
	end
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
  local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
	Background.x=display.contentCenterX
	Background.y=display.contentCenterY


  local LogoScreen = display.newText("Change Password",display.contentCenterX,display.contentCenterY-250,Font,40)
	LogoScreen:setFillColor( 0, 190/255, 1 )

  PasswordText1 = display.newText("Old Password:",display.contentCenterX-80,display.contentCenterY-100,Font,30)
	PasswordText1:setFillColor( 0, 190/255 ,1)

  PassText1 = native.newTextField(PasswordText1.x+150,PasswordText1.y,150,30)
	PassText1:addEventListener("userInput",Pass1func)
  PassText1.font = Font
  PassText1.isSecure = true

  PasswordText2 = display.newText("New Password:",display.contentCenterX-80,display.contentCenterY-50,Font,30)
	PasswordText2:setFillColor( 0, 190/255 ,1)

  PassText2 = native.newTextField(PasswordText2.x+150,PasswordText2.y,150,30)
	PassText2:addEventListener("userInput",Pass2func)
  PassText2.font = Font
  PassText2.isSecure = true

  local UpdateBTN = widget.newButton
	{
        label = "Update",
        onEvent = UpdatePas,
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
	UpdateBTN.x = display.contentCenterX
	UpdateBTN.y = display.contentCenterY+150

  local BackBTN = widget.newButton
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
	BackBTN.x = display.contentCenterX
	BackBTN.y = display.contentCenterY+200


  sceneGroup:insert(Background)
  sceneGroup:insert(LogoScreen)
  sceneGroup:insert(PasswordText1)
  sceneGroup:insert(PassText1)
  sceneGroup:insert(PasswordText2)
  sceneGroup:insert(PassText2)
  sceneGroup:insert(UpdateBTN)
  sceneGroup:insert(BackBTN)
end

--------------------------------------------------------------------------------
-- "scene:show()"
--------------------------------------------------------------------------------
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Called when the scene is still off screen (but is about to come on screen).
  elseif ( phase == "did" ) then
    -- Called when the scene is now on screen.
    -- Insert code here to make the scene come alive.
    -- Example: start timers, begin animation, play audio, etc
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
    PassText1:removeSelf()
    PassText2:removeSelf()
    composer.removeScene( "infoChange", false )
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
