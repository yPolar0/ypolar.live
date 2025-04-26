
local floor = math.floor

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue.new()
    local self = setmetatable({}, PriorityQueue)
    self:Initialize()
    return self
end

function PriorityQueue:Initialize()
    self.heap = {}
    self.current_size = 0
end

function PriorityQueue:IsEmpty()
    return self.current_size == 0
end

function PriorityQueue:GetSize()
    return self.current_size
end

function PriorityQueue:Swim()
    local heap = self.heap
    local floor = floor
    local i = self.current_size

    while floor(i / 2) > 0 do
        local half = floor(i / 2)
        if heap[i][2] < heap[half][2] then
            heap[i], heap[half] = heap[half], heap[i]
        end
        i = half
    end
end

function PriorityQueue:Put(v, p)
    self.heap[self.current_size + 1] = {v, p}
    self.current_size = self.current_size + 1
    self:Swim()
end

function PriorityQueue:Sink()
    local size = self.current_size
    local heap = self.heap
    local i = 1

    while (i * 2) <= size do
        local mc = self:min_child(i)
        if heap[i][2] > heap[mc][2] then
            heap[i], heap[mc] = heap[mc], heap[i]
        end
        i = mc
    end
end

function PriorityQueue:min_child(i)
    if (i * 2) + 1 > self.current_size then
        return i * 2
    else
        if self.heap[i * 2][2] < self.heap[i * 2 + 1][2] then
            return i * 2
        else
            return i * 2 + 1
        end
    end
end

function PriorityQueue:Pop()
    local heap = self.heap
    local retval = heap[1][1]
    heap[1] = heap[self.current_size]
    heap[self.current_size] = nil
    self.current_size = self.current_size - 1
    self:Sink()
    return retval
end

function PriorityQueue:View()
    if self.heap[1] then
        return self.heap[1][1]
    end
    return nil
end

print("[Script]: Loaded Queue!")

return PriorityQueue
