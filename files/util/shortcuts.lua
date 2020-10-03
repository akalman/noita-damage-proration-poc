function does_entity_have_variable(entity, variable_name)
    local vars = EntityGetComponent(entity, "VariableStorageComponent")
    if vars == nil or #vars == 0 then return false end

    for _,var in ipairs(vars) do
        if ComponentGetValue(var, "name") == variable_name then return true end
    end

    return false
end

function gen_modpath(path)
    return "mods/noita-damage-proration-poc/files/" .. path
end
