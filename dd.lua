-- wget https://raw.githubusercontent.com/daystram/cc-scripts/main/dd.lua
local prog_name = ...
local gists = {
    autotree = "https://raw.githubusercontent.com/daystram/cc-scripts/main/autotree.lua",
    autofarm = "https://raw.githubusercontent.com/daystram/cc-scripts/main/autofarm.lua",
    automob = "https://raw.githubusercontent.com/daystram/cc-scripts/main/automob.lua",
    master = "https://raw.githubusercontent.com/daystram/cc-scripts/main/master.lua",
    devmaster = "https://raw.githubusercontent.com/daystram/cc-scripts/main/devmaster.lua",
    devslave = "https://raw.githubusercontent.com/daystram/cc-scripts/main/devslave.lua"
}
if prog_name == nil then
    print("[E] Usage: dd [PROG_NAME]")
    return
end
if gists[prog_name] ~= nil then
    print("----- DD -----")
    print("[I] Downloading " .. prog_name)
    shell.run("rm", prog_name .. ".lua")
    shell.run("wget", gists[prog_name] .. "?nocache=" .. os.time(), prog_name .. ".lua")
    print("[I] Done!")
else
    print("[I] Program not found!")
end
