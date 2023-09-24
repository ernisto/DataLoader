--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wrapper = require(ReplicatedStorage.Packages.Wrapper)
local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataHandler<loaded, serialized> = baseLoader.DataHandler<loaded, serialized>
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Module
return function<loaded, serialized>(loader: DataLoader<loaded, serialized>, container: Instance): DataHandler<loaded, serialized>
    
    local self = wrapper(container)
    local loaders = loader.loaders
    local serializedOutput
    
    --// Methods
    function self:load(serialized)
        
        local newValues = loader:load(serialized)
        self:set(newValues)
        
        serializedOutput = serialized
        return serializedOutput
    end
    function self:set(newValues: loaded, parent: Instance?, name: string?)
        
        if parent then container.Parent = parent end
        if name then container.Name = name end
        
        for index, subLoader in loaders do
            
            local subHandler = subLoader:handle()
            local value = newValues[index]
            
            subHandler:set(value, container, index)
        end
    end
    
    --// End
    return self
end