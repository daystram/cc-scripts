-- wget https://gist.githubusercontent.com/daystram/1750d01b262e9fe236288bae036bb215/raw/dd.lua
local prog_name = ...
local gists = {
    autotree = "https://gist.githubusercontent.com/daystram/f9eac6357f2ff245af3fb997019b0daf/raw/autotree.lua",
    autofarm = "https://gist.githubusercontent.com/daystram/4fea7e3036383306d21e42fed8e0edb6/raw/autofarm.lua",
    automob = "https://gist.githubusercontent.com/daystram/d14883a5e5b1e6f8cb6021a04a603375/raw/automob.lua",
    master = "https://gist.githubusercontent.com/daystram/9805a84ee8a10f9d21f104f7a9fe8610/raw/master.lua",
    devmaster = "https://gist.githubusercontent.com/daystram/27aa05e5d8c8ef6349b4ec0755a9ee7f/raw/devmaster.lua",
    devslave = "https://gist.githubusercontent.com/daystram/a52fa122e849e559bc15bb83e36b979f/raw/devslave.lua"
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
