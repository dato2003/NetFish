-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

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

local path = system.pathForFile( "UserDB.db", system.DocumentsDirectory )
local db = sqlite3.open( path )

local tableSetup = [[CREATE TABLE IF NOT EXISTS UserDB
( UserID INTEGER PRIMARY KEY autoincrement, Username, Password, Email, Certified BOOLEAN);]]
db:exec( tableSetup )

local Username
local Password
local UsernameText
local UsernameInput
local PasswordText
local PasswordInput

function loadData()
    local sql = "select * from UserDB"
    local people = {}

    for row in db:nrows(sql) do
        people[#people+1] =
        {
          FirstName = row.Username,
    			LastName = row.Password,
					Email = row.Email,
					Certified = row.Certified
        }
    end

    return people
end

function insertData(Username, Password, Email, Certified)
    local sql = [[INSERT into UserDB (UserID, Username, Password, Email, Certified) values
		(NUll,']] .. Username .. [[',']] .. Password .. [[',']] .. Email .. [[',']] .. Certified .. [[')]]
    db:exec(sql)
end

function deleteData(id)
    local sql = [[DELETE from UserDB where UserID =']] .. id .. [['']]
    db:exec(sql)
end

function updateData(id, Info1, Info2)
    local sql = [[UPDATE UserDB set ']].. Info1 .. [[' = ']] .. Info2 .. [[' where UserID = ']] .. id .. [[']]
    db:exec(sql)
end

function UsernameHandler(event)
	if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		Username = event.target.text
		--print(Username)
	end
end

function PasswordHandler(event)
	if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		Password = event.target.text
		--print(Password)
	end
end

function Login(event)
	if(event.phase == "began") then
		if (Username ~= nil and Password ~= nil) then
			local Correct = false
			local people=loadData()
			for i=1,#people do
				print("Username:" .. people[i].FirstName .. "\nPassword:" .. people[i].LastName ..
				"\nEmail:" .. people[i].Email .. "\nCertified:" .. people[i].Certified .. "\n\n\n")
				if (Username==people[i].FirstName and Password==people[i].LastName) then
					print("logging")
					Correct=true
					composer.gotoScene( "Home","fade",500 )
				end
			end
			if (Correct==false) then
			local alert = native.showAlert( "Incorrect Password or Username","Please Enter Correct Password and Username",{"OK"})
			end
		end
	end
end

function Register(event)
	if(event.phase == "began") then
		composer.gotoScene("Register","fade",500)
	end
end

function scene:create( event )
	local sceneGroup = self.view

	local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
	Background.x=display.contentCenterX
	Background.y=display.contentCenterY

	local LogoScreen = display.newText("NetFish",display.contentCenterX,display.contentCenterY-200,native.systemFont,40)
	LogoScreen:setFillColor( 0, 190/255, 1 )

	UsernameInput = display.newText("Username:",display.contentCenterX-90,display.contentCenterY-100,native.systemFont,30)
	UsernameInput:setFillColor( 0, 190/255 ,1)

	UsernameText = native.newTextField(UsernameInput.x+150,UsernameInput.y,150,30)
	UsernameText:addEventListener("userInput",UsernameHandler)

	PasswordInput = display.newText("Password:",display.contentCenterX-90,display.contentCenterY-50,native.systemFont,30)
	PasswordInput:setFillColor( 0, 190/255 ,1)

	PasswordText = native.newTextField(PasswordInput.x+150,PasswordInput.y,150,30)
	PasswordText:addEventListener("userInput",PasswordHandler)
	PasswordText.isSecure=true

	local LoginBTN = widget.newButton
	{
        label = "Login",
        onEvent = Login,
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
	LoginBTN.x = display.contentCenterX
	LoginBTN.y = display.contentCenterY+150

	local RegisterBTN = widget.newButton
	{
        label = "Register",
        onEvent = Register,
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
	RegisterBTN.x = display.contentCenterX
	RegisterBTN.y = display.contentCenterY+200


	sceneGroup:insert(Background)
	sceneGroup:insert(LogoScreen)
	sceneGroup:insert(UsernameInput)
	sceneGroup:insert(UsernameText)
	sceneGroup:insert(PasswordInput)
	sceneGroup:insert(PasswordText)
	sceneGroup:insert(LoginBTN)
	sceneGroup:insert(RegisterBTN)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
			DBconnection:download{
        remoteFile = "/MyProjects/SocialNet/UserDB.db",
        localFile = "UserDB.db",
        onSuccess = onDownloadSuccess,
        onError = onError
			}
	elseif phase == "did" then
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
		UsernameText:removeSelf()
		PasswordText:removeSelf()
		composer.removeScene( "menu", true )
	elseif phase == "did" then
		-- Called when the scene is now off screen
		composer.removeScene( "menu", true )
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

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
