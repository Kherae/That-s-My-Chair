require "/scripts/util.lua"

function findLoungable(args, board)
	if args.position == nil then return false end

	local queryArgs = {
		order = args.orderBy,
		withoutEntityId = args.withoutEntity
	}
	
	local loungables = world.loungeableQuery(args.position, args.range, { orientation = args.orientation }, queryArgs)
	
	if #loungables > 0 then
		local buffer={}
		for _,loungableId in pairs(loungables) do
			if world.entityExists(loungableId) then
				if world.entityType(loungableId)=="object" then
					local buffer2=world.getObjectParameter(loungableId,"itemTags") or {}
					local noLounge=contains(buffer2,"noNPCLounge")
					if not noLounge then
						table.insert(buffer,loungableId)
					end
				end
			end
		end
		loungables=buffer or {}
	end
	
	if #loungables > 0 then
		if args.unoccupied then
			local unoccupied = {}
			for _,loungableId in pairs(loungables) do
				if not world.loungeableOccupied(loungableId) then
					table.insert(unoccupied, loungableId)
				end
			end
			loungables = unoccupied or {}
		end
	end

	if #loungables > 0 then
		return true, {entity = loungables[1], list = loungables}
	else
		return false
	end
end