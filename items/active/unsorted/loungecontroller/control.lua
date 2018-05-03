require "/scripts/vec2.lua"

messages={
	remSuccess={message="Access: Allowed",color={0,255,0}},
	remFail={message="Access: Allowed",color={255,0,0}},
	addSuccess={message="Access: Denied",color={0,255,0}},
	addFail={message="Access: Denied",color={255,0,0}}
}

function init()
	self=config.getParameter("primaryAbility")
	self.cooldownTimer = 0
	self.baseOffset=config.getParameter("baseOffset")
	message.setHandler("loungeController_result",parseResult)
end

function update(dt, fireMode, shiftHeld)

	self.cooldownTimer = math.max(self.cooldownTimer - dt, 0.0)

	local position = activeItem.ownerAimPosition()
	local object = world.objectAt(position)
	local rangecheck = world.magnitude(mcontroller.position(), position) <= self.maxRange and not world.lineTileCollision(vec2.add(mcontroller.position(), activeItem.handPosition(self.baseOffset)), position)
	local loungeable=false
	local tilecheck=false
	local firing=fireMode=="primary" or fireMode=="alt"
	
	if object then
		loungeable=world.getObjectParameter(object,"objectType") == "loungeable"
		if loungeable then
			tilecheck=not checkTileProtection(object, position)
		end
	end
	
	if rangecheck then
		if loungeable then
			if tilecheck then
				activeItem.setCursor("/cursors/chargeready.cursor")
			else
				activeItem.setCursor("/cursors/chargeinvalid.cursor")
			end
		else
			activeItem.setCursor("/cursors/chargeidle.cursor")
		end
	else
		activeItem.setCursor("/cursors/reticle0.cursor")
	end
	
	if self.cooldownTimer == 0 then
		if rangecheck and loungeable and tilecheck then
			if firing then
				--playSound("fire")
				self.cooldownTimer = self.cooldownTime
				world.spawnStagehand(position, "loungecontroller", {source=activeItem.ownerEntityId(),object = object, disable = (fireMode=="alt"),aimCoords=position})
			end
		else
			if firing then
				self.cooldownTimer = self.cooldownTime
				animator.playSound("error")
			end
		end
	end
end

function checkTileProtection(object, position)
	local nposition = world.entityPosition(world.objectAt(position))
	for _, v in pairs(world.objectSpaces(object)) do
		if world.isTileProtected({v[1] + nposition[1], v[2] + nposition[2]}) then return true end
	end
	return world.isTileProtected(position)
end

function parseResult(message,loc,key,coords)
	if coords and messages[key] and messages[key].color and messages[key].message then
		messageParticle(coords,messages[key].message,messages[key].color,0.6,nil,1)
	else
		--sb.logInfo("LoungeController Unhandled Message: %s",key)
	end
	playSound(key)
end

function playSound(soundKey)
	if animator.hasSound(soundKey) then
		animator.playSound(soundKey)
	end
end

function messageParticle(position, text, color, size, offset, duration, layer)
world.spawnProjectile("invisibleprojectile", position, 0, {0,0}, false,  {
        timeToLive = 0, damageType = "NoDamage", actionOnReap =
        {
            {
                action = "particle",
                specification = {
                    text =  text or "default Text",
                    color = color or {255, 255, 255, 255},  -- white
                    destructionImage = "/particles/acidrain/1.png",
                    destructionAction = "fade", --"shrink", "fade", "image" (require "destructionImage")
                    destructionTime = duration or 0.8,
                    layer = layer or "front",   -- 'front', 'middle', 'back' 
                    position = offset or {0, 2},
                    size = size or 0.7,  
                    approach = {0,20},    -- dunno what it is
                    initialVelocity = {0, 0.8},   -- vec2 type (x,y) describes initial velocity
                    finalVelocity = {0,0.5},
                    -- variance = {initialVelocity = {3,10}},  -- 'jitter' of included parameter
                    angularVelocity = 0,                                   
                    flippable = false,
                    timeToLive = duration or 2,
                    rotation = 0,
                    type = "text"                 -- our best luck
                }
            } 
        }
    }
    )
end