local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureFolder(name, parent)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local remotesFolder = ensureFolder("Remotes", ReplicatedStorage)

local function getOrMake(name, className)
	local inst = remotesFolder:FindFirstChild(name)
	if not inst then
		inst = Instance.new(className)
		inst.Name = name
		inst.Parent = remotesFolder
	end
	return inst
end

local api = {
	PushBoxRequest = getOrMake("PushBoxRequest", "RemoteEvent"),
	BoxMoved = getOrMake("BoxMoved", "RemoteEvent"),
	RoundState = getOrMake("RoundState", "RemoteEvent"),
	SubmitTime = getOrMake("SubmitTime", "RemoteFunction"),
	AdminReset = getOrMake("AdminReset", "RemoteFunction"),
	BuildLevel = getOrMake("BuildLevel", "BindableEvent"), -- server->server
	SubmitBestTime = getOrMake("SubmitBestTime", "BindableEvent"), -- server->server
}
return api
