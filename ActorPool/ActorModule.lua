
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

	Sum = function(...)
		local total = 0
		for _, number in ipairs({...}) do
			total += number
		end
		return total
	end,

}

function Module.HandleCommand( command : string | number, ... : any? ) : any?
	assert( Module.Commands[command], 'No such command in actor commands! ' .. tostring(command) )
	return Module.Commands[command](...)
end

function Module.Init()

end

function Module.Start()

	-- ConnectParallel automatically starts desynchronized
	OutboundEvent.Event:ConnectParallel(function( UUID : string, ParamCounter : number, command : string, arguments : { any? } )
		if ActorUUID == UUID then
			local result = { pcall(Module.HandleCommand, command, unpack(arguments)) }
			local success = table.remove(result, 1)
			-- WRITE PARALLEL ENABLED
			InboundEvent:Fire( UUID, ParamCounter, success, result )
		end
	end)

end

return Module
