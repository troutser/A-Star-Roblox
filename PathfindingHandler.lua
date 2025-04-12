local PathfindingHandler = {}
PathfindingHandler.__index = PathfindingHandler

local DEFAULTS = {
	h = -1,
	g = -1,
	Origin = "None",
	Color = Color3.fromRGB(89, 255, 249)
}
function PathfindingHandler:heuristic(a, b)
	return math.round((a-b).Magnitude*10)/10
end
function PathfindingHandler:neighbors(position)
	local neighbors = {}
	for x = -1, 1 do
		if not self[x+position.X] then continue end
		for y = -1, 1 do
			if not self[x+position.X][y+position.Y] then continue end
			for z = -1, 1 do
				if not self[x+position.X][y+position.Y][z+position.Z] then colocal PathfindingHandler = {}
PathfindingHandler.__index = PathfindingHandler

local DEFAULTS = {
	h = -1,
	g = -1,
	Origin = "None",
	Color = Color3.fromRGB(89, 255, 249)
}
function PathfindingHandler:heuristic(a, b)
	return math.round((a-b).Magnitude*10)/10
end
function PathfindingHandler:neighbors(position)
	local neighbors = {}
	for x = -1, 1 do
		if not self[x+position.X] then continue end
		for y = -1, 1 do
			if not self[x+position.X][y+position.Y] then continue end
			for z = -1, 1 do
				if not self[x+position.X][y+position.Y][z+position.Z] then continue end
				
				local neighbor = Vector3.new(x,y,z)
				
				if neighbor == Vector3.new(0,0,0) then continue end
				if self[x+position.X][y+position.Y][z+position.Z].Blocked then continue end
				
				table.insert(neighbors, neighbor+position)
			end
		end
	end

	return neighbors
end
function PathfindingHandler:explore(position, finish)
	self[position.X][position.Y][position.Z].h = self:heuristic(position, finish)
	local CurrentPosition = self[position.X][position.Y][position.Z]
	local Neighbors = self:neighbors(position)
	
	for _, NeighborPosition in Neighbors do
		self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].h = self:heuristic(NeighborPosition, finish)

		if self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g == DEFAULTS.g then 
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g = CurrentPosition.g + self:heuristic(position, NeighborPosition)
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Origin = position
		elseif self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g > CurrentPosition.g + self:heuristic(position, NeighborPosition)  then
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g = CurrentPosition.g + self:heuristic(position, NeighborPosition)
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Origin = position
		end
	end
	
	return Neighbors
end
function PathfindingHandler.new(size)
	local NavigationGrid = {}
	
	NavigationGrid.Size = size
	
	for x = 1, size.X do
		NavigationGrid[x] = {}
		for y = 1, size.Y do
			NavigationGrid[x][y] = {}
			for z = 1, size.Z do
				NavigationGrid[x][y][z] = {
					Position = Vector3.new(x,y,z),
					h = DEFAULTS.h,
					g = DEFAULTS.g,
					Explored = false,
					Origin = DEFAULTS.Origin,
					_Color = DEFAULTS.Color
				}
			end
		end
	end
	
	setmetatable(NavigationGrid, PathfindingHandler)
	
	return NavigationGrid
end

function PathfindingHandler:visualize(padding, partSize)
	for _, part in workspace.Parts:GetChildren() do
		part:Destroy()
	end
	for x = 1, self.Size.X do
		for y = 1, self.Size.Y do
			for z = 1, self.Size.Z do
				local Part = Instance.new("Part")
				local Cell = self[x][y][z]
				Part.Anchored = true
				Part.Size = partSize
				Part.Position = Vector3.new(x,y,z)*padding
				Part.Color = self[x][y][z]._Color
				Part.Name = string.format("h: %.2f  g: %.2f  f: %.2f", Cell.h, Cell.g, Cell.h + Cell.g)
				Part.Transparency = 0.5
				
				Part.Parent = workspace.Parts
			end
		end
	end
end
function PathfindingHandler:block(position)
	self[position.X][position.Y][position.Z]._Color = Color3.new(0, 0, 0)
	self[position.X][position.Y][position.Z].Blocked = true
end
function PathfindingHandler:pathfind(startPosition, finish, visualize, secondInbetweenVisualizations, padding, size)
	if (visualize and not padding) or (visualize and not size) then padding = Vector3.new(1,1,1) size = padding end
	
	local CurrentPosition = startPosition
	local FinishPosition = finish
	
	self[CurrentPosition.X][CurrentPosition.Y][CurrentPosition.Z].g = 0
	self[CurrentPosition.X][CurrentPosition.Y][CurrentPosition.Z].h = self:heuristic(startPosition, finish)
	
	local Explored = {}
	while CurrentPosition ~= FinishPosition do
		local Neighbors = self:explore(CurrentPosition, finish)
		
		for _, NeighborPosition in Neighbors do
			if self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Explored then continue end --neighbor already explored, no need to add to explored list
			
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Explored = true --flag neighbor as already explored
			table.insert(Explored, NeighborPosition) -- add to explored list
		end
		--find the node in explored with lowest composite f value, using lowest h cost as the tie breaker for same f values 
		local LowestComposite = math.huge
		local hOfLowest = math.huge
		local PositionWithLowest = nil
		local IndexOfLowest = nil
		
		for Index, Position in Explored do
			if Position == FinishPosition then  --found end position, stop and break loop
				PositionWithLowest = Position
				IndexOfLowest = 1
				break
			end
			local node = self[Position.X][Position.Y][Position.Z]
			local f = node.g + node.h
			if f < LowestComposite then
				LowestComposite = f
				PositionWithLowest = Position
				hOfLowest = node.h
				IndexOfLowest = Index
			end
			if f == LowestComposite then
				if hOfLowest > node.h then
						LowestComposite = f
						PositionWithLowest = Position
						IndexOfLowest = Index
						hOfLowest = node.h
				end
			end
		end
		table.remove(Explored, IndexOfLowest)
		CurrentPosition = PositionWithLowest
		
		self[CurrentPosition.X][CurrentPosition.Y][CurrentPosition.Z]._Color = Color3.fromRGB(255, 0, 0)
		
		--option to visualize
		if not visualize then continue end
		
		task.wait(secondInbetweenVisualizations)
		self:visualize(padding, size)
	end
	local endPosition = finish
	local path = {finish}
	
	while endPosition ~= startPosition do
		table.insert(path, self[endPosition.X][endPosition.Y][endPosition.Z].Origin)
		endPosition =  self[endPosition.X][endPosition.Y][endPosition.Z].Origin
	end
	
	for _, position in path do
		self[position.X][position.Y][position.Z]._Color = Color3.fromRGB(113, 255, 61)
	end
	
	if not visualize then return end

	task.wait(secondInbetweenVisualizations)
	self:visualize(padding, size)
end

return PathfindingHandlertinue end
				
				local neighbor = Vector3.new(x,y,z)
				
				if neighbor == Vector3.new(0,0,0) then continue end
				if self[x+position.X][y+position.Y][z+position.Z].Blocked then continue end
				
				table.insert(neighbors, neighbor+position)
			end
		end
	end

	return neighbors
end
function PathfindingHandler:explore(position, finish)
	self[position.X][position.Y][position.Z].h = self:heuristic(position, finish)
	local CurrentPosition = self[position.X][position.Y][position.Z]
	local Neighbors = self:neighbors(position)
	
	for _, NeighborPosition in Neighbors do
		self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].h = self:heuristic(NeighborPosition, finish)

		if self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g == DEFAULTS.g then 
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g = CurrentPosition.g + self:heuristic(position, NeighborPosition)
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Origin = position
		elseif self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g > CurrentPosition.g + self:heuristic(position, NeighborPosition)  then
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].g = CurrentPosition.g + self:heuristic(position, NeighborPosition)
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Origin = position
		end
	end
	
	return Neighbors
end
function PathfindingHandler.new(size)
	local NavigationGrid = {}
	
	NavigationGrid.Size = size
	
	for x = 1, size.X do
		NavigationGrid[x] = {}
		for y = 1, size.Y do
			NavigationGrid[x][y] = {}
			for z = 1, size.Z do
				NavigationGrid[x][y][z] = {
					Position = Vector3.new(x,y,z),
					h = DEFAULTS.h,
					g = DEFAULTS.g,
					Explored = false,
					Origin = DEFAULTS.Origin,
					_Color = DEFAULTS.Color
				}
			end
		end
	end
	
	setmetatable(NavigationGrid, PathfindingHandler)
	
	return NavigationGrid
end

function PathfindingHandler:visualize(padding, partSize)
	for _, part in workspace.Parts:GetChildren() do
		part:Destroy()
	end
	for x = 1, self.Size.X do
		for y = 1, self.Size.Y do
			for z = 1, self.Size.Z do
				local Part = Instance.new("Part")
				local Cell = self[x][y][z]
				Part.Anchored = true
				Part.Size = partSize
				Part.Position = Vector3.new(x,y,z)*padding
				Part.Color = self[x][y][z]._Color
				Part.Name = string.format("h: %.2f  g: %.2f  f: %.2f", Cell.h, Cell.g, Cell.h + Cell.g)
				Part.Transparency = 0.5
				
				Part.Parent = workspace.Parts
			end
		end
	end
end
function PathfindingHandler:block(position)
	self[position.X][position.Y][position.Z]._Color = Color3.new(0, 0, 0)
	self[position.X][position.Y][position.Z].Blocked = true
end
function PathfindingHandler:pathfind(startPosition, finish, visualize, secondInbetweenVisualizations, padding, size)
	if (visualize and not padding) or (visualize and not size) then padding = Vector3.new(1,1,1) size = padding end
	
	local CurrentPosition = startPosition
	local FinishPosition = finish
	
	self[CurrentPosition.X][CurrentPosition.Y][CurrentPosition.Z].g = 0
	self[CurrentPosition.X][CurrentPosition.Y][CurrentPosition.Z].h = self:heuristic(startPosition, finish)
	
	local Explored = {}
	while CurrentPosition ~= FinishPosition do
		local Neighbors = self:explore(CurrentPosition, finish)
		
		for _, NeighborPosition in Neighbors do
			if self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Explored then continue end --neighbor already explored, no need to add to explored list
			
			self[NeighborPosition.X][NeighborPosition.Y][NeighborPosition.Z].Explored = true --flag neighbor as already explored
			table.insert(Explored, NeighborPosition) -- add to explored list
		end
		--find the node in explored with lowest composite f value, using lowest h cost as the tie breaker for same f values 
		local LowestComposite = math.huge
		local hOfLowest = math.huge
		local PositionWithLowest = nil
		local IndexOfLowest = nil
		
		for Index, Position in Explored do
			if Position == FinishPosition then  --found end position, stop and break loop
				PositionWithLowest = Position
				IndexOfLowest = 1
				break
			end
			local node = self[Position.X][Position.Y][Position.Z]
			local f = node.g + node.h
			if f < LowestComposite then
				LowestComposite = f
				PositionWithLowest = Position
				hOfLowest = node.h
				IndexOfLowest = Index
			end
			if f == LowestComposite then
				if hOfLowest > node.h then
						LowestComposite = f
						PositionWithLowest = Position
						IndexOfLowest = Index
						hOfLowest = node.h
				end
			end
		end
		table.remove(Explored, IndexOfLowest)
		CurrentPosition = PositionWithLowest
		
		self[CurrentPosition.X][CurrentPosition.Y][CurrentPosition.Z]._Color = Color3.fromRGB(255, 0, 0)
		
		--option to visualize
		if not visualize then continue end
		
		task.wait(secondInbetweenVisualizations)
		self:visualize(padding, size)
	end
	local endPosition = finish
	local path = {finish}
	
	while endPosition ~= startPosition do
		table.insert(path, self[endPosition.X][endPosition.Y][endPosition.Z].Origin)
		endPosition =  self[endPosition.X][endPosition.Y][endPosition.Z].Origin
	end
	
	for _, position in path do
		self[position.X][position.Y][position.Z]._Color = Color3.fromRGB(113, 255, 61)
	end
	
	if not visualize then return end

	task.wait(secondInbetweenVisualizations)
	self:visualize(padding, size)
end

return PathfindingHandler
