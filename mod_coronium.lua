--[[
Coronium module for Corona SDK v1.90
Copyright (c) 2014 C. Byerley
More info http://coronium.io
]]--
local json = require("json")
local url = require("socket.url")
local mime = require("mime")

local Coronium = 
{
  appId = nil,
  apiKey = nil,
  
  showStatus = false,
  showAlert = false,
  showJSON = false,
  
  endpoint = "coronium/1/",

  sessionToken = nil,

  --Event Dispatcher
  dispatcher = display.newGroup(),
  --Requests
  requestQueue = {},
  
  --Coronium type constants
  NIL = nil,
  ERROR = "ERROR",
  EXPIRED = 101,
  USER = "users",
  PUSH = "push",
  OBJECT = "objects",
  ANALYTICS = "analytics",
  CLOUD = "code",
  FILE = "files",
  LOGIN = "login",
  LOGOUT = "logout",
  RESET = "requestPasswordReset",

  --action constants
  POST = "POST",
  GET = "GET",
  PUT = "PUT",
  DELETE = "DELETE",
  
  --upload types
  TEXT = "text/plain",
  PNG = "image/png",
  JPG = "image/jpeg",
  MOV = "video/quicktime",
  M4V = "video/x-m4v",
  MP4 = "video/mp4",
  ZIP = "application/zip"

}

--------------------------------------------------------------------- 
-- Coronium API USERS
---------------------------------------------------------------------  
function Coronium:getUser( userId, _callback )
  local uri = Coronium:getEndpoint( Coronium.USER .. "/" .. userId )
  return self:sendRequest( uri, {}, Coronium.USER, Coronium.GET, _callback )
end

function Coronium:registerUser( userDataTable, _callback )
  local uri = Coronium:getEndpoint( Coronium.USER )

  --You must set up SSL on the Coronium server for
  --true enecryption over the wire using HTTPS.
  --for more information visit http://docs.coronium.io
  userDataTable.password = mime.b64( userDataTable.password )

  return self:sendRequest( uri, userDataTable, Coronium.USER, Coronium.POST, _callback )
end

function Coronium:updateUser( userDataTable, _callback )
  assert( self.sessionToken, "Session token required. Log in." )

  local token = self:getSessionToken()

  local uri = Coronium:getEndpoint( Coronium.USER .. "/" .. token )
  return self:sendRequest( uri, userDataTable, Coronium.USER, Coronium.PUT, _callback )
end

function Coronium:loginUser( email, password, _callback )
  local uri = Coronium:getEndpoint( Coronium.LOGIN )

  --You must set up SSL on the Coronium server for
  --true enecryption over the wire using HTTPS.
  --for more information visit http://docs.coronium.io
  local password = mime.b64( password )

  local queryTable = { email = email, password = password }
  return self:sendQuery( uri, queryTable, Coronium.LOGIN, _callback )
end

function Coronium:logoutUser( _callback )
  assert( self.sessionToken, "Session token required. Log in." )

  local uri = Coronium:getEndpoint( Coronium.LOGOUT )
  return self:sendQuery( uri, {}, Coronium.LOGOUT, _callback )
end

function Coronium:getMe( _callback )
  assert( self.sessionToken, "Session token required. Log in." )

  local uri = Coronium:getEndpoint( Coronium.USER .. "/me" )
  return self:sendQuery( uri, {}, Coronium.USER, _callback )
end

function Coronium:requestPassword( email, _callback )
  assert( email, "Email address missing." )

  local uri = Coronium:getEndpoint( Coronium.RESET )
  return self:sendQuery( uri, { email = email }, Coronium.RESET, _callback )
end

--user devices
function Coronium:linkUserDevice( deviceToken, pushbotsAction, _callback )
  assert( self.sessionToken, "Session token required. Log in." )

  local tags = tags or {}

  local data = 
  { 
    action = "adddevice", 
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken,
    pushbotsAction = pushbotsAction or nil
  }

  local uri = Coronium:getEndpoint( Coronium.USER .. "/" .. Coronium:getSessionToken() )
  return self:sendRequest( uri, data, Coronium.USER, Coronium.PUT, _callback )
end

function Coronium:unlinkUserDevice( deviceToken, pushbotsAction, _callback )
  assert( self.sessionToken, "Session token required. Log in." )

  local data = 
  { 
    action = "removedevice",
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken,
    pushbotsAction = pushbotsAction or nil
  }

  local uri = Coronium:getEndpoint( Coronium.USER .. "/" .. Coronium:getSessionToken() )
  return self:sendRequest( uri, data, Coronium.USER, Coronium.PUT, _callback )
end
--------------------------------------------------------------------- 
-- Coronium PUSH OBJECT
--------------------------------------------------------------------- 
function Coronium:addInstallation( deviceToken, tags )
  local tags = tags or ""

  local data = 
  { 
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken,
    tags = tags
  }

  local uri = Coronium:getEndpoint( Coronium.PUSH .. "/" )
  return self:sendRequest( uri, data, Coronium.PUSH, Coronium.POST, _callback )
end

function Coronium:removeInstallation( deviceToken )
  local data = 
  { 
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken
  }

  local uri = Coronium:getEndpoint( Coronium.PUSH .. "/" )
  return self:sendRequest( uri, data, Coronium.PUSH, Coronium.PUT, _callback )
end

function Coronium:addDeviceTag( deviceToken, tag )
  local data = 
  { 
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken,
    tag = tostring( tag )
  }

  local uri = Coronium:getEndpoint( Coronium.PUSH .. "/tag" )
  return self:sendRequest( uri, data, Coronium.PUSH, Coronium.POST, _callback )
end

function Coronium:removeDeviceTag( deviceToken, tag )
  local data = 
  { 
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken,
    tag = tostring( tag )
  }

  local uri = Coronium:getEndpoint( Coronium.PUSH .. "/tag" )
  return self:sendRequest( uri, data, Coronium.PUSH, Coronium.PUT, _callback )
end

function Coronium:setBadgeCount( deviceToken, badgeCount )
  local data = 
  { 
    devicePlatform = Coronium:getPlatform(), 
    deviceToken = deviceToken,
    badgeCount = badgeCount
  }

  local uri = Coronium:getEndpoint( Coronium.PUSH .. "/badge" )
  return self:sendRequest( uri, data, Coronium.PUSH, Coronium.PUT, _callback )
end
--------------------------------------------------------------------- 
-- Coronium API OBJECT
---------------------------------------------------------------------  
function Coronium:createObject( objClass, objDataTable, _callback )
  local uri = Coronium:getEndpoint( Coronium.OBJECT .. "/" .. objClass )
  return self:sendRequest( uri, objDataTable, Coronium.OBJECT, Coronium.POST, _callback )
end

function Coronium:getObject( objClass, objId, _callback  )
  local uri = Coronium:getEndpoint( Coronium.OBJECT .. "/" .. objClass .. "/" .. objId )
  return self:sendRequest( uri, {}, Coronium.OBJECT, Coronium.GET, _callback )
end

function Coronium:updateObject( objClass, objId, objDataTable, _callback )
  local uri = Coronium:getEndpoint( Coronium.OBJECT .. "/" .. objClass .. "/" .. objId )
  return self:sendRequest( uri, objDataTable, Coronium.OBJECT, Coronium.PUT, _callback )
end

function Coronium:deleteObject( objClass, objId, _callback  )
  local uri = Coronium:getEndpoint( Coronium.OBJECT .. "/" .. objClass .. "/" .. objId )
  return self:sendRequest( uri, {}, Coronium.OBJECT, Coronium.DELETE, _callback )
end

--query based
function Coronium:getObjects( objClass, queryTable, _callback  )
  queryTable = queryTable or {}
  local uri = Coronium:getEndpoint( Coronium.OBJECT .. "/" .. objClass )
  return self:sendQuery( uri, queryTable, Coronium.OBJECT, _callback )
end
--------------------------------------------------------------------- 
-- Coronium API FILE
-- Special thanks to Rob Miracle @MiracleMan
---------------------------------------------------------------------  
function Coronium:uploadFile( fileMetaTable, _callback, _progress_callback )
  
  --filename, directory
  
  assert( fileMetaTable.filename, "A filename is required in the meta table")

  local fileName = fileMetaTable.filename
  local directory = fileMetaTable.baseDir or system.TemporaryDirectory

  local _progress_callback = _progress_callback or nil
  
  --determine mime
  local contentType = self:getMimeType( fileName )

  if contentType then
  
    local fileParams = self:newFileParams( contentType )
    fileParams.headers["filename"] = fileName

    local q = { 
      requestId = network.upload(
        self.endpoint .. self.FILE,
        -- self.endpoint .. self.FILE .. "/" .. fileName,
        self.PUT,
        function(e) self:onResponse(e); end,
        fileParams,
        fileName,
        directory,
        contentType 
      ),
      requestType = self.FILE,
      _callback = _callback,
      _progress_callback = _progress_callback,
    }
    table.insert( self.requestQueue, q )
    
    return q.requestId

  else
    print( "Content type not supported" )
  end
  
end
--------------------------------------------------------------------- 
-- Coronium API ANALYTICS
---------------------------------------------------------------------  
function Coronium:appOpened( _callback )
  local uri = Coronium:getEndpoint( Coronium.ANALYTICS .. "/opened" )

  local analytics = {}

  analytics.deviceType = Coronium:getPlatform()

  analytics.appName = system.getInfo( "appName" )
  analytics.appVersion = system.getInfo( "appVersionString" )
  analytics.deviceModel = system.getInfo( "model" )

  return self:sendRequest( uri, analytics, Coronium.ANALYTICS, Coronium.POST, _callback )
end

function Coronium:addEvent( eventType, eventTag, _callback )
  local uri = Coronium:getEndpoint( Coronium.ANALYTICS .. "/event" )

  assert( eventType, "addEvent(): Requires eventType and eventTag" )
  assert( eventTag, "addEvent(): Requires eventType and eventTag" )

  local analytics = {}

  analytics.deviceType = Coronium:getPlatform()

  analytics.appName = system.getInfo( "appName" )
  analytics.appVersion = system.getInfo( "appVersionString" )
  analytics.deviceModel = system.getInfo( "model" )

  analytics.event = eventType
  analytics.tag = eventTag

  return self:sendRequest( uri, analytics, Coronium.ANALYTICS, Coronium.POST, _callback )
end

function Coronium:removeEvent( eventType, eventTag, amount, _callback )

  local uri = Coronium:getEndpoint( Coronium.ANALYTICS .. "/event-remove" )

  assert( eventType, "removeEvent(): Requires eventType and eventTag" )
  assert( eventTag, "removeEvent(): Requires eventType and eventTag" )
  
  local amount = amount or 1

  local analytics = {}

  analytics.event = eventType
  analytics.tag = eventTag
  analytics.amount = amount

  return self:sendRequest( uri, analytics, Coronium.ANALYTICS, Coronium.POST, _callback )

end

function Coronium:dropEvent( eventType, _callback )
  local uri = Coronium:getEndpoint( Coronium.ANALYTICS .. "/event-drop" )

  assert( eventType, "removeEvent(): Requires eventType and eventTag" )

  local analytics = {}

  analytics.event = eventType

  return self:sendRequest( uri, analytics, Coronium.ANALYTICS, Coronium.POST, _callback )

end

function Coronium:dropEventTag( eventType, eventTag, _callback )
  local uri = Coronium:getEndpoint( Coronium.ANALYTICS .. "/event-tag-drop" )

  assert( eventType, "dropEventTag(): Requires eventType and eventTag" )
  assert( eventTag, "dropEventTag(): Requires eventType and eventTag" )

  local analytics = {}

  analytics.event = eventType
  analytics.tag = eventTag

  return self:sendRequest( uri, analytics, Coronium.ANALYTICS, Coronium.POST, _callback )

end
--------------------------------------------------------------------- 
-- Coronium API CLOUD FUNCTIONS
---------------------------------------------------------------------
function Coronium:run( functionName, functionParams, _callback )
  functionParams = functionParams or {}
  
  local uri = Coronium:getEndpoint( Coronium.CLOUD .. "/" .. functionName )
  return self:sendRequest( uri, functionParams, Coronium.CLOUD, Coronium.POST, _callback )
end

---------------------------------------------------------------------
-- Coronium Module Internals
---------------------------------------------------------------------

-- REQUESTS --
function Coronium:buildRequestParams( withDataTable, masterKey )
  local postData = json.encode( withDataTable )
  return self:newRequestParams( postData, masterKey ) --for use in a network request
end

function Coronium:sendRequest( uri, requestParamsTbl, requestType, action, _callback, masterKey )
  local requestParams = self:buildRequestParams( requestParamsTbl, masterKey )
  
  requestType = requestType or Coronium.NIL
  action = action or Coronium.POST

  local q = { 
    requestId = network.request( uri, action, function(e) Coronium:onResponse(e); end, requestParams ),
    requestType = requestType,
    _callback = _callback,
  }
  table.insert( self.requestQueue, q )
  
  return q.requestId
end

-- QUERIES --
function Coronium:buildQueryParams( withQueryTable )
  local uri = ""
  for key, v in pairs( withQueryTable ) do
    if uri ~= "" then
      uri = uri .. "&"
    end
    
    local value = v
    if key == "where" then
      value = url.escape( json.encode( v ) )
    end
    
    uri = uri .. tostring( key ) .. "=" .. value
    
  end
  return self:newRequestParams( uri ) --for use in a network request
end

function Coronium:sendQuery( uri, queryParamsTbl, requestType, _callback )
  local requestParams = self:buildQueryParams( queryParamsTbl )

  requestType = requestType or Coronium.NIL
  --action = action or Coronium.GET
  
  local queryUri = uri .. "?" .. requestParams.body

  local q = { requestId = network.request( queryUri, Coronium.GET, function(e) Coronium:onResponse(e); end, requestParams ),
    requestType = requestType,
    _callback = _callback,
  }
  table.insert( self.requestQueue, q )
  
  return q.requestId
end

-- FILES  --
function Coronium:buildFileParams( withDataTable )
  local postData = json.encode( withDataTable )
  return self:newRequestParams( postData ) --for use in a network request
end

-- SESSION --
function Coronium:setSessionToken( sessionId )
  self.sessionToken = sessionId
  return self.sessionToken
end

function Coronium:getSessionToken()
  return self.sessionToken
end

function Coronium:clearSessionToken()
  self.sessionToken = nil
end

-- RESPONSE --
function Coronium:onResponse( event )
  if event.phase == "ended" then
  
    local status = event.status
    local requestId = event.requestId

    local response = { response = nil, error = nil, errorCode = nil }

    if status == -1 then
      response.error = "Timed out"
      response.errorCode = status
    elseif status >= 200 and status < 400 then

        local ok, result = pcall( function()
          return json.decode( event.response ) 
        end)

        if ok then
          if result ~= nil then
            if result.error then
              response.error = result.error
              response.errorCode = result.errorCode
            else
              response.result = result.result
              --check for session
              if type(response.result) == 'table' and response.result.sessionToken then
                self:setSessionToken( response.result.sessionToken )
              end
            end
          else
            --result wasnt sent
            response.error = "Server output missing.  Use coronium.output()"
            response.errorCode = -99
          end
        else
          response.error = "Data could not be decoded"
          response.errorCode = -2
        end

    elseif status >= 400 and status < 500 then
      response.error = "Resource Not Found"
      response.errorCode = status
    elseif status >= 500 then
      response.error = "Server Error - Check Logs"
      response.errorCode = status
    end

    if self.showJSON then
      print( event.response )
    end

    if self.showStatus then
      Coronium:printTable( response )
    end

    if self.showAlert then
      local msg
      if response.error then
        msg = "error: " .. response.error
        if response.errorCode then
          msg = msg .. "\nerrorCode: " .. response.errorCode
        end
      else
        msg = "Success"
      end

      native.showAlert( "Coronium!", msg , { "OK" } )
    end
    
    --find request
    local requestType = Coronium.NIL
    local _callback = nil
    for r=1, #self.requestQueue do
      local request = self.requestQueue[ r ]
      if request.requestId == requestId then
        requestType = request.requestType
        _callback = request._callback
        table.remove( self.requestQueue, r )
        break
      end
    end

    --broadcast response
    local e = {
      name = "coroniumResponse",
      requestId = requestId,
      requestType = requestType,
      result = response.result,
      error = response.error,
      errorCode = response.errorCode
    }

    --broadcast it
    if e ~= nil then
      if _callback then
        _callback( e )
      else --use global event
        self.dispatcher:dispatchEvent( e )
      end
    else
      print( "FATAL ERROR OCCURED!" ) 
    end

  elseif event.phase == "progress" then --files
    
    local status = event.status or nil
    local requestId = event.requestId or 0
    local bytesTransferred = event.bytesTransferred or 0
    local url = event.url or ""

    --== Find callback
    local _callback = nil
    for r=1, #self.requestQueue do
      local request = self.requestQueue[ r ]
      if request.requestId == requestId then
        _progress_callback = request._progress_callback
        break
      end
    end

    if _progress_callback then
      local e = {
        name = "coroniumProgress",
        requestId = requestId,
        response = nil,
        status = status,
        phase = "progress",
        bytesTransferred = bytesTransferred
      }

      _progress_callback( e )
    end
  end
end

function Coronium:newRequestParams( bodyData, masterKey )
  --set up headers
  local headers = {}
  headers["X-Coronium-APP-ID"] = self.appId
  headers["X-Coronium-API-KEY"] = self.apiKey
  
  --session?
  if self.sessionToken then
    headers["X-Coronium-Session-Token"] = self:getSessionToken()
  end
  
  --masterkey?
  if masterKey then
    headers["X-Coronium-Master-Key"] = masterKey
  end
  
  headers["Content-Type"] = "application/json"

  --populate parameters for the network call
  local requestParams = {}
  requestParams.headers = headers
  requestParams.body = bodyData

  return requestParams
end

-- FILE PARAMS
function Coronium:newFileParams( contentType )
  --set up headers
  local headers = {}
  headers["X-Coronium-APP-ID"] = self.appId
  headers["X-Coronium-API-KEY"] = self.apiKey
  
  local requestParams = {}

  headers["Content-Type"] = contentType

  --populate parameters for the network call
  requestParams = {}
  requestParams.headers = headers
  requestParams.timeout = 60
  requestParams.progress = true
  requestParams.bodyType = "binary"

  return requestParams
end

function Coronium:getEndpoint( typeConstant )
  return self.endpoint .. typeConstant
end

function Coronium:cancelRequest( requestId )
  network.cancel( requestId )
end

function Coronium:getMimeType( filePath )

  local path = string.lower( filePath )
  local mime = nil

  if string.find( path, ".txt" ) ~= nil then
    mime = self.TEXT
  elseif string.find( path, ".jpg" ) ~= nil then
    mime = self.JPG
  elseif string.find( path, ".jpeg" ) ~= nil then
    mime = self.JPG
  elseif string.find( path, ".png" ) ~= nil then
    mime = self.PNG
  elseif string.find( path, ".mov" ) ~= nil then
    mime = self.MOV
  elseif string.find( path, ".mp4" ) ~= nil then
    mime = self.MP4
  elseif string.find( path, ".m4v" ) ~= nil then
    mime = self.M4V
  elseif string.find( path, ".zip" ) ~= nil then
    mime = self.ZIP
  end
  
  return mime
end

function Coronium:timestampToISODate( unixTimestamp )
  --2013-12-03T19:01:25Z"
  unixTimestamp = unixTimestamp or os.time()
  return os.date( "!%Y-%m-%dT%H:%M:%SZ", unixTimestamp )
end

function Coronium:getPlatform()
  local platformName = system.getInfo( "platformName" )
  if platformName == "Android" then
    return "android"
  elseif platformName == "iPhone OS" then
    return "ios"
  else
    return "unknown" --devin' 'unknown' is default
  end
end

function Coronium:printTable( t, indent )
-- print contents of a table, with keys sorted. second parameter is optional, used for indenting subtables
  local names = {}
  if not indent then indent = "" end
  for n,g in pairs(t) do
      table.insert(names,n)
  end
  table.sort(names)
  for i,n in pairs(names) do
      local v = t[n]
      if type(v) == "table" then
          if(v==t) then -- prevent endless loop if table contains reference to itself
              print(indent..tostring(n)..": <-")
          else
              print(indent..tostring(n)..":")
              Coronium:printTable(v,indent.."   ")
          end
      else
          if type(v) == "function" then
              print(indent..tostring(n).."()")
          else
              print(indent..tostring(n)..": "..tostring(v))
          end
      end
  end
end

function Coronium:init( o )
  self.appId = o.appId
  self.apiKey = o.apiKey

  local domain = "http://"
  --== https?
  if o.https then
    domain = "https://"
  end
  self.endpoint = domain .. self.appId .. "/1/"
  
end

return Coronium
