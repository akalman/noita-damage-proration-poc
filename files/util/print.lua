function table_print(tt)
	local output = ""
	if type(tt) == "table" then
		output = output .. "{"
		local needs_prefix = false

		for key, value in pairs (tt) do
			if needs_prefix then
				output = output .. ","
			else
				needs_prefix = true
			end
			if type (value) == "table" then
				output = output .. string.format("\"%s\":%s", tostring(key), table_print(value))
			else
				output = output .. string.format("\"%s\":\"%s\"", tostring(key), tostring(value))
			end
		end

		output = output .. "}"
	else
		output = tostring(tt)
	end
	return output
end

function create_component_obj(component_id)
	return {
		members = ComponentGetMembers(component_id)
	}
end

function create_entity_obj(entity_id)
	local entity = {
		parent = EntityGetParent(entity_id),
		name = EntityGetName(entity_id),
		tags = EntityGetTags(entity_id),
		components = {},
		children = {}
	}

	local components = EntityGetAllComponents(entity_id)
	if not (components == nil) then
		for _,component_id in ipairs(components) do
			entity.components[component_id] = create_component_obj(component_id)
		end
	end

	local children = EntityGetAllChildren(entity_id)
	if not (children == nil) then
		for _,child_id in ipairs(children) do
			entity.children[child_id] = create_entity_obj(child_id)
		end
	end

	return entity
end

function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and Random(0, 0xf) or Random(8, 0xb)
        return string.format('%x', v)
    end)
end
