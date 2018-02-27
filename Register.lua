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

local path = system.pathForFile( "UserDB.db", system.DocumentsDirectory )
local db = sqlite3.open( path )

local Username
local Password
local Email
local UsernameText
local UsernameInput
local PasswordText
local PasswordInput
local EmailText
local EmailInput


function loadData()
    local sql = "select * from UserDB"
    local people = {}

    for row in db:nrows(sql) do
        people[#people+1] =
        {
          FirstName = row.Username,
    			LastName = row.Password
        }
    end

    return people
end

function insertData(Username, Password, Email, Certified)
    local sql = [[INSERT into UserDB (UserID, Username, Password, Email, Certified)values
    (NUll,']] .. Username .. [[',']] .. Password .. [[',']] .. Email .. [[',']] .. Certified .. [[' )]]
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
function Upload(LocalName,RemoteName)
    DBconnection:upload{
      localFile = system.pathForFile(LocalName, system.DocumentsDirectory),
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


function Back(event)
    if event.phase == "began" then
        composer.gotoScene( "menu","fade",500 )
    end
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

function EmailHandler(event)
	if ( event.phase == "began" ) then

  elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		Email = event.target.text
		--print(Password)
	end
end

function RegisterFunc(event)
    if ( event.phase == "began") then
        if (Username ~= nil and Password ~= nil and Email ~= nil) then
          print("logging")
          insertData(Username,Password,Email,0)
          Upload("UserDB.db","UserDB.db")
          composer.gotoScene( "menu","fade",500 )
        end
    end
end

function scene:create( event )
  local sceneGroup = self.view

  local LogoScreen = display.newText("NetFish",display.contentCenterX,display.contentCenterY-230,native.systemFont,70)
	LogoScreen:setFillColor( 0, 190/255, 1 )

  local Background = display.newImageRect("Background.jpg",display.actualContentWidth,display.actualContentHeight)
  Background.x=display.contentCenterX
	Background.y=display.contentCenterY

  UsernameInput = display.newText("Username:",display.contentCenterX-90,display.contentCenterY-150,native.systemFont,30)
	UsernameInput:setFillColor( 0, 190/255 ,1)

	UsernameText = native.newTextField(UsernameInput.x+150,UsernameInput.y,150,30)
	UsernameText:addEventListener("userInput",UsernameHandler)

	PasswordInput = display.newText("Password:",display.contentCenterX-90,display.contentCenterY-100,native.systemFont,30)
	PasswordInput:setFillColor( 0, 190/255 ,1)

	PasswordText = native.newTextField(PasswordInput.x+150,PasswordInput.y,150,30)
	PasswordText:addEventListener("userInput",PasswordHandler)
	PasswordText.isSecure=true

  EmailInput = display.newText("Email:",display.contentCenterX-90,display.contentCenterY-50,native.systemFont,30)
	EmailInput:setFillColor( 0, 190/255 ,1)

	EmailText = native.newTextField(EmailInput.x+150,EmailInput.y,150,30)
	EmailText:addEventListener("userInput",EmailHandler)


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


  local RegisterBTN = widget.newButton
	{
        label = "Register",
        onEvent = RegisterFunc,
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
	RegisterBTN.y = display.contentCenterY+150

  sceneGroup:insert(Background)
  sceneGroup:insert(LogoScreen)
  sceneGroup:insert(BackBTN)
  sceneGroup:insert(UsernameInput)
  sceneGroup:insert(UsernameText)
  sceneGroup:insert(PasswordInput)
  sceneGroup:insert(PasswordText)
  sceneGroup:insert(EmailInput)
  sceneGroup:insert(EmailText)
  sceneGroup:insert(RegisterBTN)
end


function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then

  end
end


function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    composer.removeScene( "Register", true )
  end
end


function scene:destroy( event )
  local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--------------------------------------------------------------------------------

return scene
