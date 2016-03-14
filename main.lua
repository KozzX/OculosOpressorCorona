local Admob = require( "Admob" )
local Oculos = require( "Oculos" ) 
local store = require( "plugin.google.iap.v3" )

-- This function gets called when the user opens a notification or one is received when the app is open and active.
-- Change the code below to fit your app's needs.
function DidReceiveRemoteNotification(message, additionalData, isActive)
    if (additionalData) then
        if (additionalData.discount) then
            native.showAlert( "Discount!", message, { "OK" } )
            -- Take user to your app store
        elseif (additionalData.actionSelected) then -- Interactive notification button pressed
            native.showAlert("Button Pressed!", "ButtonID:" .. additionalData.actionSelected, { "OK"} )
        elseif (additionalData.shop) then
            store.purchase("remove_ads")
        elseif (additionalData.like) then
            if(not system.openURL("fb://page/1083605381668906")) then
                system.openURL("http://www.facebook.com/opressoroculos")
            end
        elseif (additionalData.update) then   
            system.openURL("https://play.google.com/store/apps/details?id=com.athgames.oculosopressor")
        elseif(additionalData.minigame) then
            system.openURL("https://play.google.com/store/apps/details?id=com.athgames.minigameracer")
        end
    else
        native.showAlert("OneSignal Message", message, { "OK" } )
    end
end

local OneSignal = require("plugin.OneSignal")
OneSignal.Init("f9f7063b-47d4-4f2a-a592-dbadff39204f", "912620755640", DidReceiveRemoteNotification)


local globals = require( "globals" )
local coronium = require( "mod_coronium" )

display.setDefault( "background", 0.2, 0.2, 0.2)

coronium:init({ appId = globals.appId, apiKey = globals.apiKey })

--coronium.showStatus = true
coronium:addEvent( "StartApp", "start" )




widget.setTheme( "widget_theme_ios7" )


propaganda = true
local link
local cartBar
local btnCart

function loja( event )
    local transaction = event.transaction

    --native.showAlert( "Restore", transaction.state, { "Ok" } )

    if ( transaction.state == "purchased" ) then
        propaganda = false
        link.alpha = 0
        cartBar.alpha = 0
        btnCart.alpha = 0
        hideBanner()
    elseif ( transaction.state == "cancelled" ) then
        native.showAlert( "Cancelada", "Compra cancelada", { "Ok"} )
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
    elseif ( transaction.state == "failed" ) then
        native.showAlert( "Erro", "Item não comprado", { "Ok"} )
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
    else
        print( "Unknown event" )
    end
    store.finishTransaction( transaction )
end
store.init( "google", loja )

store.restore( )



init()
loadInter()
showBanner()

local adCont = 1
local g = 1
local selecionado = 0
local oculos = {}

local grupo = display.newGroup( )
local hudGroup = display.newGroup( )
local menuGroup = display.newGroup( )

local aspect

local hudView = true
local menuView = false

local image = display.newImage( "doge.jpg", display.contentCenterX, display.contentCenterY )

print(display.contentWidth,display.contentHeight)

print(image.width,image.height)

if image.width >= image.height then
    aspect = image.width / image.height
    image.width = display.contentWidth
    image.height = display.contentWidth / aspect    
else
    aspect = image.width / image.height
    image.width = display.contentHeight * aspect
    image.height = display.contentHeight
    if image.width > display.contentWidth then
        aspect = image.width / image.height
        image.width = display.contentWidth
        image.height = display.contentWidth / aspect  
    end
end


local flash = display.newRect( display.contentCenterX,0, display.contentWidth * 2, display.contentHeight * 2)
flash.alpha = 0
--flash.anchorX = 0
flash.anchorY = 0
flash:toFront( )

local fade = display.newRect( display.contentCenterX,0, display.contentWidth * 2, display.contentHeight * 2)
fade:setFillColor( 0,0,0 )
fade.alpha = 0
--fade.anchorX = 0
fade.anchorY = 0
fade:toFront( )

local tabela = display.newRoundedRect( display.contentCenterX, -display.contentCenterY/2 , display.contentWidth / 1.2, display.contentCenterY, 20 )
tabela:setFillColor( 0.7,0.7,0.7 )
local menuOculos = Oculos.new()
local menuThug = Oculos.newThug()
local menuDeal = Oculos.newDeal()
local menuBlack = Oculos.newBlack()

menuOculos.id = "oculos"
menuThug.id = "thug"
menuDeal.id = "deal"
menuBlack.id = "black"

menuOculos.y = tabela.y - tabela.height / 2 /2
menuDeal.y = tabela.y
menuThug.y = tabela.y + tabela.height / 2 /2
menuBlack.y = tabela.y

print( tabela.y - tabela.height / 2 /2,tabela.y + tabela.height / 2 /2,tabela.y )

menuGroup:insert( tabela )
menuGroup:insert( menuOculos )
menuGroup:insert( menuThug )
menuGroup:insert( menuDeal )
menuGroup:insert( menuBlack )


local btnLoading = display.newImage("loading.png", display.contentWidth/2 , display.contentHeight / 2)
btnLoading:scale( 3, 3 )
btnLoading.alpha = 0

local function spin(  )
    btnLoading:rotate( 10 )
end
Runtime:addEventListener( "enterFrame", spin )




-- create object
--local oculos = display.newImage("oculos.png", display.contentCenterX, display.contentCenterY)

link = display.newText( "bit.ly/oculosplus", display.contentCenterX, image.y + (image.height / 2) - (image.height / 100 ), native.systemFont, 60 )    

link.anchorY = 1
link:setFillColor( 0.7,0.7,0.7 )

grupo:insert( image )
grupo:insert( link )



--- Slider listener
local function sliderScale( event )
    if event.phase == "moved" then
        if selecionado > 0 then
            print( "Slider at " .. event.value .. "%",oculos[selecionado].xScale )
            oculos[selecionado].xScale = event.value / 40
            oculos[selecionado].yScale = event.value / 40
        end
    elseif event.phase == "ended" then
        if (adCont % 10) == 0 then
            timer.performWithDelay( 1000, function (  )
                showInter( )
                loadInter( )
                print( "imprimiu" )
            end , 1 )
            
        end
        adCont = adCont + 1
        --coronium:addEvent( "SliderScale", event.value .. "%" ) 
    end

end

-- Create the widget
local sliScale = widget.newSlider
{
    top = 60,
    left = 40,
    width = 300,
    value = 50,  
    listener = sliderScale
}

local function sliderRotation( event )
    if event.phase == "moved" then
        if selecionado > 0 then
            print( "Slider at " .. event.value .. "%",oculos[selecionado].rotation )
            oculos[selecionado].rotation = event.value * 1.8 - 90
        end
    elseif event.phase == "ended" then
        if (adCont % 10) == 0 then
            timer.performWithDelay( 1000, function (  )
                showInter( )
                loadInter( )
                print( "imprimiu" )
            end , 1 )
            
        end
        adCont = adCont + 1
        --coronium:addEvent( "SliderRotation", event.value .. "%" ) 
    end

end

-- Create the widget
local sliRot = widget.newSlider
{
    top = 60,
    left = display.contentWidth - 40 - 300,
    width = 300,
    value = 50,  
    listener = sliderRotation
}

-- touch listener function
function selectOculos( event )
    if event.phase == "began" then
        print( event.target.index)
        selecionado = event.target.index
        
        sliScale:setValue( oculos[selecionado].xScale * 40 )
        sliRot:setValue( (oculos[selecionado].rotation + 90) / 1.8 )

        
        oculos[selecionado]:toFront( )
        oculos[selecionado].markX = oculos[selecionado].x    -- store x location of object
        oculos[selecionado].markY = oculos[selecionado].y    -- store y location of object
 
    elseif event.phase == "moved" then
 
        local x = (event.x - event.xStart) + oculos[selecionado].markX
        local y = (event.y - event.yStart) + oculos[selecionado].markY
       
        oculos[selecionado].x, oculos[selecionado].y = x, y    -- move object based on calculations above
 
    --verifica quando a tela deixou de ser tocada    
    elseif event.phase == "ended" then
        if (adCont % 10) == 0 then
            timer.performWithDelay( 1000, function (  )
                showInter( )
                loadInter( )
                print( "imprimiu" )
            end , 1 )
            
        end
        adCont = adCont + 1

        --coronium:addEvent( "Oculos", event.x .. "x" .. event.y )
    end
   
    return true
end
     

function addOculos( event )
    if (adCont % 5) == 0 then
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
        
    end
    adCont = adCont + 1
    print(event)
    if event == "oculos" then
        oculos[g] = Oculos.new()     
    elseif event.target.id == "oculos" then
        oculos[g] = Oculos.new()    
    elseif event.target.id == "thug" then
        oculos[g] = Oculos.newThug()
    elseif event.target.id == "deal" then
        oculos[g] = Oculos.newDeal()
    elseif event.target.id == "black" then
        oculos[g] = Oculos.newBlack() 
    end
    oculos[g].index = g
    grupo:insert( oculos[g] )
    oculos[g]:addEventListener( "touch", selectOculos )
    selecionado = g
    sliScale:setValue( oculos[selecionado].xScale * 40 )
    sliRot:setValue( (oculos[selecionado].rotation + 90) / 1.8 )
    g = g + 1
    if event ~= "oculos" then
        transition.to( tabela, {y = -display.contentCenterY/2, time= 200} )
        transition.to( menuOculos, {y=-(560),time= 200})
        transition.to( menuDeal, {y=-(399),time= 200})
        transition.to( menuThug, {y=-(230),time= 200})
        transition.to( menuBlack, {y=-(100),time= 200})    
        
        menuView = false
        timer.performWithDelay( 400, function (  )
            menuOculos:removeEventListener( "tap", addOculos )
            menuThug:removeEventListener( "tap", addOculos )
            menuDeal:removeEventListener( "tap", addOculos )
            menuBlack:removeEventListener( "tap", addOculos )
        end ,1 ) 
    end
end

addOculos("oculos")

function deleteOculos( event )
    if (adCont % 5) == 0 then
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )   
    end
    adCont = adCont + 1
    if selecionado > 0 then
        transition.to( oculos[selecionado], {alpha=0,time=400,onComplete=function (  )
            oculos[selecionado]:removeEventListener( "touch", selectOculos )
            display.remove(oculos[selecionado])
            oculos[selecionado] = nil
            selecionado = 0
        end} )
        
    end
end



--local btnGallery = Botao.new("Gallery",80)
local topBar = display.newRect( display.contentCenterX, 0, display.contentWidth * 2, display.contentHeight / 100 * 10 )
local bottomBar = display.newRect( display.contentCenterX, display.contentHeight / 100 * 94, display.contentWidth * 2, display.contentHeight / 100 * 20 )
local viewBar = display.newRoundedRect( display.contentWidth/2 - 140, display.contentHeight / 100 * 88, 128, 90, 10 )
cartBar = display.newRoundedRect( display.contentWidth/2 + 295, display.contentHeight / 100 * 13.5, 128, 90, 10 )
local btnScale = display.newImage("scale.png", display.contentWidth / 2 / 2 + 10, display.contentHeight / 100 * 1)
local btnRotate = display.newImage("rotate.png", (display.contentWidth/2) + display.contentCenterX / 2 - 10, display.contentHeight / 100 * 2)

local btnCamera = display.newImage("camera.png", display.contentWidth/2 + 45, display.contentHeight / 100 * 88)
local btnGallery = display.newImage("folder.png", display.contentWidth/2 + 140, display.contentHeight / 100 * 88)
local btnShare = display.newImage("share.png", display.contentWidth/2 + 310, display.contentHeight / 100 * 88)
local btnSave = display.newImage("save.png", display.contentWidth/2 - 45, display.contentHeight / 100 * 88)
local btnView = display.newImage("view.png", display.contentWidth/2 - 140, display.contentHeight / 100 * 88)
local btnPlus = display.newImage("plus.png", display.contentWidth/2 - 230 , display.contentHeight / 100 * 88)
local btnTrash = display.newImage("trash.png", display.contentWidth/2 + 230, display.contentHeight / 100 * 88)
local btnLike = display.newImage("like.png", display.contentWidth/2 - 310, display.contentHeight / 100 * 88)
btnCart = display.newImage("cart.png", display.contentWidth/2 + 295, display.contentHeight / 100 * 13.5)

topBar:setFillColor( 0.8,0.8,0.8 )
viewBar:setFillColor( 0.8,0.8,0.8 )
cartBar:setFillColor( 0.8,0.8,0.8 )
topBar.anchorY = 0
bottomBar:setFillColor( 0.8,0.8,0.8 )
btnScale:scale(0.4,0.4) 
btnRotate:scale(0.4,0.4) 
btnScale.anchorY = 0
btnRotate.anchorY = 0
topBar.alpha = 0.6
bottomBar.alpha = 0.6
cartBar.alpha = 0.6
viewBar.alpha = 0
viewBar:scale( 0.6, 0.6 )
btnCamera:scale( 0.6, 0.6 ) 
btnGallery:scale( 0.6, 0.6 ) 
btnShare:scale( 0.6, 0.6 )  
btnSave:scale( 0.6, 0.5 ) 
btnView:scale( 0.65, 0.7 )
btnPlus:scale( 0.6, 0.5 )
btnTrash:scale( 0.6, 0.5)
btnLike:scale( 0.5, 0.5)
btnCart:scale( 0.7, 0.7)


hudGroup:insert( topBar )
hudGroup:insert( sliRot )
hudGroup:insert( sliScale )
hudGroup:insert(btnScale)
hudGroup:insert(btnRotate)
hudGroup:insert(bottomBar)
hudGroup:insert(btnCamera)
hudGroup:insert(btnGallery)
hudGroup:insert(btnShare)
hudGroup:insert(btnSave)
hudGroup:insert(btnPlus)
hudGroup:insert(btnTrash)
hudGroup:insert(btnLike)
hudGroup:insert(cartBar)
hudGroup:insert(btnCart)


local function menu( event )
    if (adCont % 5) == 0 then
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
        
    end
    adCont = adCont + 1
    if menuView == false then
        transition.to( tabela, {y = display.contentCenterY/2, time= 200} )
        transition.to( menuOculos, {y=(100),time= 200})
        transition.to( menuDeal, {y=(230),time= 200})
        transition.to( menuThug, {y=(399),time= 200})
        transition.to( menuBlack, {y=(560),time= 200})
        
        menuView = true    
        timer.performWithDelay( 400, function (  )
            menuOculos:addEventListener( "tap", addOculos )
            menuThug:addEventListener( "tap", addOculos )
            menuDeal:addEventListener( "tap", addOculos )
            menuBlack:addEventListener( "tap", addOculos )

        end ,1 )
        
    else
        transition.to( tabela, {y = -display.contentCenterY/2, time= 200} )
        transition.to( menuOculos, {y=-(560),time= 200})
        transition.to( menuDeal, {y=-(399),time= 200})
        transition.to( menuThug, {y=-(230),time= 200})
        transition.to( menuBlack, {y=-(100),time= 200})    
        
        menuView = false
        timer.performWithDelay( 400, function (  )
            menuOculos:removeEventListener( "tap", addOculos )
            menuThug:removeEventListener( "tap", addOculos )
            menuDeal:removeEventListener( "tap", addOculos )
            menuBlack:removeEventListener( "tap", addOculos )
        end ,1 )   
        
    end
end

btnPlus:addEventListener( "tap", menu )
btnTrash:addEventListener( "tap", deleteOculos )

local function shareListener( event )
    coronium:addEvent( "Share", "shared" )    
end

local options = {
    
    url = "http://bit.ly/oculosplus",
    image = {
        { filename = "deal3.jpg", baseDir = system.TemporaryDirectory }
    },
    listener = shareListener
}

local function piscar(  )
    flash:toFront( )
    transition.to( flash, {alpha = 1, time = 50, onComplete = function (  )
        transition.to( flash, {alpha = 0, time = 500} )
        print( "piscou" )
    end} )
end

local function carregar(  )
    fade:toFront( )
    fade.alpha=0.5
    btnLoading.alpha = 1
end


local function share(  )
    
    piscar()
    timer.performWithDelay( 600, function (  )
        display.save( grupo, "deal3.jpg", system.TemporaryDirectory )
        native.showPopup( "social", options )
        coronium:addEvent( "Share", "clicado" )
    end, 1 )
    
    
end
btnShare:addEventListener( "tap", share )



local function onPhotoComplete( event )
    display.remove(image)
    image = nil
    image = event.target

    if (adCont % 5) == 0 then
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
        
    end
    adCont = adCont + 1

    if image then
        -- center image on screen
        coronium:addEvent( "Gallery", "selecionou" )
        coronium:addEvent( "GalleryPhotoSize", image.width .. "x" .. image.height )

        

        
        image.x = display.contentCenterX
        image.y = display.contentCenterY
        if image.width >= image.height then
            aspect = image.width / image.height
            image.width = display.contentWidth
            image.height = display.contentWidth / aspect    
        else
            aspect = image.width / image.height
            image.width = display.contentHeight * aspect
            image.height = display.contentHeight
            if image.width > display.contentWidth then
                aspect = image.width / image.height
                image.width = display.contentWidth
                image.height = display.contentWidth / aspect  
            end
        end
        link.y =  image.y + (image.height / 2) - (image.height / 100 )

        display.save( image, "originalGallery3.jpg", system.TemporaryDirectory )

        grupo:insert(image)
        image:toBack( )
    
    end
    
end

local function gallery(  )
    if media.hasSource( media.PhotoLibrary ) then
        coronium:addEvent( "Gallery", "abriu" )
        media.selectPhoto( { mediaSource = media.PhotoLibrary, listener = onPhotoComplete } )
    else
        coronium:addEvent( "Gallery", "nogallery" )
        native.showAlert( "Corona", "This device does not have a photo library.", { "OK" } )
    end
end
btnGallery:addEventListener( "tap", gallery )



local sessionComplete = function(event)
    display.remove( image ) 
    image = nil
    image = event.target

    if (adCont % 5) == 0 then
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
        
    end
    adCont = adCont + 1

    if image then

        coronium:addEvent( "Camera", "tirou" )
        coronium:addEvent( "CameraPhotoSize", image.width .. "x" .. image.height )
        
        -- center image on screen    
        image.x = display.contentCenterX
        image.y = display.contentCenterY
        if image.width >= image.height then
            aspect = image.width / image.height
            image.width = display.contentWidth
            image.height = display.contentWidth / aspect    
        else
            aspect = image.width / image.height
            image.width = display.contentHeight * aspect
            image.height = display.contentHeight
            if image.width > display.contentWidth then
                aspect = image.width / image.height
                image.width = display.contentWidth
                image.height = display.contentWidth / aspect  
            end
        end
        link.y =  image.y + (image.height / 2) - (image.height / 100 )

        display.save( image, "originalCamera3.jpg", system.TemporaryDirectory )

        grupo:insert(image)
        image:toBack( )
    end
end

local camera = function( event )
    if media.hasSource( media.Camera ) then
        coronium:addEvent( "Camera", "abriu" )
        media.capturePhoto( { listener = sessionComplete } )
    else
        coronium:addEvent( "Camera", "nocamera" )
        native.showAlert("Corona", "Camera not found.")
    end
    return true
end
btnCamera:addEventListener( "tap", camera )




local function saved( event )
    coronium:addEvent( "Save", "salva" )
    if event.action == "clicked" then
        fade.alpha = 0
        btnLoading.alpha = 0
    end    

end


local function save( event )
    piscar()
    timer.performWithDelay( 1000, function (  )
        carregar()
        timer.performWithDelay( 300, function (  )
            display.save( grupo, "save3.jpg", system.TemporaryDirectory )
            local captura = display.capture( grupo, { saveToPhotoLibrary=true, isFullResolution=false } )
            coronium:addEvent( "SavePhotoSize", captura.width .. "x" .. captura.height )
            display.remove( captura )
            timer.performWithDelay( 600, function (  )
                if (adCont % 5) == 0 then
                    timer.performWithDelay( 1200, function (  )
                        showInter( )
                        loadInter( )
                        print( "imprimiu" )
                    end , 1 )
                end
                adCont = adCont + 1
                native.showAlert( "Sucesso", "Imagem salva na galeria." , { "Ok" }, saved )
            end , 1)        
        end , 1 )    
    end , 1 )
    
    
end

btnSave:addEventListener( "tap", save )


local function view( event )
    if (adCont % 5) == 0 then
        timer.performWithDelay( 1000, function (  )
            showInter( )
            loadInter( )
            print( "imprimiu" )
        end , 1 )
        
    end
    adCont = adCont + 1
    if hudView == true then
        coronium:addEvent( "View", "false" )
        transition.to( hudGroup, {alpha=0, time = 300} )    
        transition.to( viewBar, {alpha=0.6, time = 300} )
        hudView = false
    else 
        coronium:addEvent( "View", "true" )
        transition.to( hudGroup, {alpha=1, time = 300} )  
        transition.to( viewBar, {alpha=0, time = 300} )
        hudView = true
    end

end
btnView:addEventListener( "tap", view )

local function like( event )
    if(not system.openURL("fb://page/1083605381668906")) then
        coronium:addEvent( "Like", "url" )
        system.openURL("http://www.facebook.com/opressoroculos")
    else
        coronium:addEvent( "Like", "app" )
    end 
end

btnLike:addEventListener( "tap", like )

local function onFacebook( event )
    if event.action == "clicked" then
        local i = event.index
        if i == 1 then
            
        elseif i == 2 then
            if(not system.openURL("fb://page/1083605381668906")) then
                coronium:addEvent( "Like", "shopUrl" )
                system.openURL("http://www.facebook.com/opressoroculos")
            else
                coronium:addEvent( "Like", "shopApp" )
            end
        end
    end    
end

local function shop( event )
    local function onShop( event )
        if event.action == "clicked" then
            local i = event.index
            if i == 1 then
                coronium:addEvent( "Shop", "yes" )
                store.purchase("remove_ads")
            elseif i == 2 then
                coronium:addEvent( "Shop", "no" )
                timer.performWithDelay( 1200, function (  )
                    showInter( )
                    loadInter( )
                    print( "imprimiu" )
                end , 1 )
            end
        end    
    end
    native.showAlert( "Usuário Premium", "Deseja ser um usuário premium e remover os anúncios e a marca d'água?", { "Sim","Não" }, onShop )
end

btnCart:addEventListener( "tap", shop )
