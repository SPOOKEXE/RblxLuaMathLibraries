
local ActorInstance = script.Parent
local ActorUUID = ActorInstance:GetAttribute('UUID')

local OutboundEvent = ActorInstance:WaitForChild('OutboundReference').Value :: BindableEvent
local InboundEvent = ActorInstance:WaitForChild('InboundReference').Value :: BindableEvent

assert( typeof(ActorUUID) == 'string', 'Actor was not given a UUID.' )
assert( typeof(OutboundEvent) == 'Instance' and OutboundEvent:IsA('BindableEvent'), 'Actor was not given a reference to the bindable event.' )
assert( typeof(InboundEvent) == 'Instance' and InboundEvent:IsA('BindableEvent'), 'Actor was not given a reference to the bindable event.' )

-- // Module // --
local Module = {}

Module.Commands = {
	Vec3Mag = function( _ : number, vec0 : Vector3, vec1 : Vector3 ) : number
		-- task.wait(0.1)
		return (vec1 - vec0).Magnitude
	end,

	DecodePixelRow = function( RowList )
		local basePixel = '<font color=rgb(%s,%s,%s)>%s</font>'
		local Pixels = {}
		for _, Value in ipairs( RowList ) do
			local count, value = 1, Value
			if typeof(Value) == 'string' then
				count, value = string.split(Value, 'y')
				count = tonumber(count)
				local r, g, b = string.split(value, ',')
				value = { tonumber(r), tonumber(g), tonumber(b) }
			end
			table.insert(Pixels, string.format(basePixel, unpack(value), string.rep('|', count)))
		end
		return Pixels
	end,
}

function Module.HandleCommand( command : string | number, ... : any? ) : any?
	assert( Module.Commands[command], 'No such command in actor commands! ' .. tostring(command) )
	return Module.Commands[command](...)
end

function Module.Init()

end

function Module.Start()

	OutboundEvent.Event:ConnectParallel(function( UUID : string, ParamCounter : number, command : string, arguments : { any? } )
		if ActorUUID == UUID then
			local result = { pcall(Module.HandleCommand, command, unpack(arguments)) }
			local success = table.remove(result, 1)
			InboundEvent:Fire( UUID, ParamCounter, success, result )
		end
	end)

end

return Module
