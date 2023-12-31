--// Packages
local baseLoader = require(script.Parent.Parent.base)
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

local xtypeof = require(script.Parent.utils).xtypeof
local handler = require(script.handler)

--// Module
return function<loaded>(_loaders: loaded & { [string]: any })
    
    local loaders = {} :: { [string]: DataLoader<any, any> }
    
    local self: DataLoader<loaded, { [string]: any }>, meta = baseLoader()
    self.kind = "struct"
    self.loaders = loaders
    
    --// Override Methods
    function self:getDefaultData()
        
        local defaultData = {}
        
        for index, loader in loaders do
            
            defaultData[index] = loader:getDefaultData()
        end
        
        return defaultData
    end
    
    function self:check(data)
        
        assert(typeof(data) == "table", `table expected`)
        
        for index, loader in loaders do
            
            if loader.isOptional then continue end
            loader:check(data[index])
        end
    end
    function self:correct(data)
        
        if typeof(data) ~= "table" then return end
        
        local corrections = {}  -- logs corrections here instead apply changes without know if was possible correct all fields
        
        for index, loader in loaders do
            
            if loader:tryCheck(data[index]) then continue end
            
            if not loader.canCorrect then return end
            local correction = loader:correct(data[index]) or loader:getDefaultData()
            
            if correction == nil then return end
            corrections[index] = correction
        end
        
        for index, correction in corrections do
            
            data[index] = correction
        end
        
        return data
    end
    
    function self:deserialize(data)
        
        local values = {}
        
        for index, loader in loaders do
            
            values[index] = loader:deserialize(data[index])
        end
        
        return values
    end
    function self:serialize(values)
        
        local data = {}
        
        for index, loader in loaders do
            
            data[index] = loader:serialize(values[index])
        end
        
        return data
    end
    
    function self:wrapHandler(container)
        
        return handler(self, container or Instance.new("Folder"))
    end
    
    --// Methods
    function self:insert(index, value)
        
        local loader = if xtypeof(value) == "DataLoader" then value else baseLoader(value)
        rawset(self, index, loader)
        
        loaders[index] = loader
        return loader
    end
    function self:extend(subLoaders: { [string]: any })
        
        for index, value in subLoaders do
            
            self:insert(index, value)
        end
        
        return self
    end
    
    --// Behaviour
    function meta:__newindex(index, value)
        
        if index == "defaultData" or index == "rootContainer" then return rawset(self, index, value) end
        self:insert(index, value)
    end
    
    --// Setup
    for index, value in _loaders do
        
        self:insert(index, value)
    end
    
    --// End
    return self
end