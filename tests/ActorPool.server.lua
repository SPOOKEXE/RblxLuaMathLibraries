
local ServerStorage = game:GetService('ServerStorage')
local ActorPoolModule = require(ServerStorage:WaitForChild('ActorPool'))

ActorPoolModule.SetTargetActorAmount( 1000 )

local function GenerateRandomVector( min, max )
	return Vector3.new( math.random(min, max), math.random(min, max), math.random(min, max) )
end

local ArgumentTable = { }
for index = 1, 100000 do
	table.insert( ArgumentTable, { index, GenerateRandomVector( -100, 100 ), GenerateRandomVector( -100, 100 ) } )
end

print('==== Distributing Calculations ====')

local OrderedResult = ActorPoolModule.DistributeCalculation(
	'Vec3Mag',
	ArgumentTable,
	false, -- create more actors if needed
	true -- cleanup extra actors (TargetActorCount)
)

print('==== Calculations Completed ====')

local Mag = (ArgumentTable[#ArgumentTable][2] - ArgumentTable[#ArgumentTable][3]).Magnitude
print( 'Manual Calculation: ', Mag )
print( 'Actor Result: ', OrderedResult[#OrderedResult][1] )
print( 'Is Correct: ', Mag == OrderedResult[#OrderedResult][1] )

print('==== Secondary Calculations Completed ====')
