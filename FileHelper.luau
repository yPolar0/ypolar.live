local http_service = game:GetService("HttpService");

local files = {}; do
	function files:check_folder(path)
		if type(path) ~= "string" then return false, "Invalid path" end
		if not isfolder or not makefolder then return false, "Executor missing 'folder' functions" end

		if not isfolder(path) then
			pcall(makefolder, path)
			repeat task.wait() until isfolder(path)
		end

		return true
	end

	function files:delete_folder(path)
		if type(path) ~= "string" then return false, "Invalid path" end
		if not isfolder or not delfolder then return false, "Executor missing 'folder' functions" end

		if isfolder(path) then
			pcall(delfolder, path)
			repeat task.wait() until not isfolder(path)
		end

		return true
	end

	function files:check_file(path, content)
		if type(path) ~= "string" then return false, "Invalid path" end
		if not isfile or not writefile then return false, "Executor missing 'file' functions" end

		if not isfile(path) then
			local data = (type(content) == "table" and http_service:JSONEncode(content)) or (content or "")
			pcall(writefile, path, data)
			repeat task.wait() until isfile(path)
		end

		return true
	end

	function files:write_file(path, content)
		if type(path) ~= "string" then return false, "Invalid path" end
		if not writefile then return false, "Executor missing 'writefile' function" end

		local data = (type(content) == "table" and http_service:JSONEncode(content)) or (content or "")
		pcall(writefile, path, data)

		return true
	end

	function files:delete_file(path)
		if type(path) ~= "string" then return false, "Invalid path" end
		if not isfile or not delfile then return false, "Executor missing 'file' functions" end

		if isfile(path) then
			pcall(delfile, path)
			repeat task.wait() until not isfile(path)
		end

		return true
	end

	function files:read_file(path, as_table)
		if type(path) ~= "string" then return false, "Invalid path" end
		if not isfile or not readfile then return false, "Executor missing 'file' function" end

		if isfile(path) then
			local success, result = pcall(readfile, path)
			if success then
				if as_table then
					local ok, decoded = pcall(http_service.JSONDecode, http_service, result)
					return ok and decoded or result
				end
				return result
			end
		end

		return false, "File does not exist"
	end

	function files:list_files(path, ext)
		if type(path) ~= "string" or not isfolder(path) then return false, "Invalid folder path" end
		if not listfiles then return false, "Executor missing 'listfiles' function" end

		local result = {}
		for _, full_path in ipairs(listfiles(path)) do
			local file_name = full_path:match("([^/\\]+)$") or full_path
			if ext == "json" and file_name:match("%.json$") then
				table.insert(result, file_name:sub(1, -6))
			elseif ext == "lua" and file_name:match("%.lua$") then
				table.insert(result, file_name:sub(1, -5))
			elseif not ext then
				table.insert(result, file_name)
			end
		end
		return result
	end
end

return files
