require "/scripts/util.lua"

function init()
	self.object = config.getParameter("object", 0)
	self.disable = config.getParameter("disable", false)
	self.source = config.getParameter("source",0)
	self.aimCoords = config.getParameter("aimCoords")
end

function update(dt)
	local itemTags = world.getObjectParameter(self.object, "itemTags") or {}
	if self.disable then
		local i=contains(itemTags,"noNPCLounge")
		if i then
			itemTags[i]=nil
			world.callScriptedEntity(self.object, "object.setConfigParameter", "itemTags", itemTags)
			if world.entityExists(self.source) then
				world.sendEntityMessage(self.source,"loungeController_result","remSuccess",self.aimCoords)
			end
		else
			if world.entityExists(self.source) then
				world.sendEntityMessage(self.source,"loungeController_result","remFail",self.aimCoords)
			end
		end
	else
		local i=contains(itemTags,"noNPCLounge")
		if not i then
			table.insert(itemTags,"noNPCLounge")
			world.callScriptedEntity(self.object, "object.setConfigParameter", "itemTags", itemTags)
			if world.entityExists(self.source) then
				world.sendEntityMessage(self.source,"loungeController_result","addSuccess",self.aimCoords)
			end
		else
			if world.entityExists(self.source) then
				world.sendEntityMessage(self.source,"loungeController_result","addFail",self.aimCoords)
			end
		end
	end
	stagehand.die()
end