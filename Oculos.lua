function new(  )
	local oculos = display.newImage("oculos.png", display.contentCenterX, display.contentCenterY)
	oculos.alpha = 0
	transition.to( oculos, {alpha=1,time=400} )
	return oculos
end

function newThug(  )
	local oculos = display.newImage("thug.png", display.contentCenterX, display.contentCenterY)
	oculos.alpha = 0
	transition.to( oculos, {alpha=1,time=400} )
	return oculos
end

function newDeal(  )
	local oculos = display.newImage("deall.png", display.contentCenterX, display.contentCenterY)
	oculos.alpha = 0
	oculos.width = oculos.width / 2
	oculos.height = oculos.height / 2

	transition.to( oculos, {alpha=1,time=400} )
	return oculos
end

function newBlack(  )
	local oculos = display.newRect( display.contentCenterX, display.contentCenterY, 400,80)
	oculos:setFillColor( 0,0,0 )
	oculos.alpha = 0
	transition.to( oculos, {alpha=1,time=400} )
	return oculos
end

return {
	new = new,
	newThug = newThug,
	newDeal = newDeal,
	newBlack = newBlack
}