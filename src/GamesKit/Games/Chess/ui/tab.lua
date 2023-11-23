-- Stonetr03

local Module = {}

function Module:Compare(a,b)
    local Same = true
    for i,v in pairs(a) do
        if typeof(v) == "table" then
            if typeof(b[i]) == "table" then
                -- Both Tables
                if Module:Compare(a[i],b[i]) == false then
                    Same = false
                end
            else
                Same = false
            end
        else
            if b[i] and b[i] == v then else
                Same = false
            end
        end
    end
    for i,v in pairs(b) do
        if typeof(v) == "table" then
            if typeof(a[i]) == "table" then
                -- Both Tables
                if Module:Compare(a[i],b[i]) == false then
                    Same = false
                end
            else
                Same = false
            end
        else
            if a[i] and a[i] == v then else
                Same = false
            end
        end
    end
    return Same
end

function ProcessTable(t)
    local NewTab = {}
    for i,v in pairs(t) do
        if typeof(v) == "table" then
            NewTab[i] = table.clone(ProcessTable(v))
        else
            NewTab[i] = v
        end
    end
    return NewTab
end
function Module:Clone(Data)
    if typeof(Data) == "table" then
        return ProcessTable(table.clone(Data))
    else
        return Data
    end
end

function Module:Find(Haystack: table,Needle: any)
    local Found = nil
    for i,o in pairs(Haystack) do
        if typeof(Needle) == "table" and typeof(o) == "table" then
            if Module:Compare(o,Needle) == true then
                Found = i
                break
            end
        else
            if o == Needle then
                Found = i
                break
            end
        end
    end
    return Found
end

return Module
