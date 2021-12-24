START_CLK = os.clock()
M_PSTATUS = "PSTATUS"
M_PREGISTER = "PREGISTER"
M_PCOMMAND = "PCOMMAND"
M_MID = nil
M_MHOST = "master"
STATUS = "-1"

ATK_DELAY = 0.5

function init()
    rednet.open("left")
    rednet.unhost(M_PSTATUS, os.getComputerLabel())
    M_MID = rednet.lookup(M_PSTATUS, M_MHOST)
    while M_MID == nil do
        print("[M] Cannot find master!")
        print("[M] Retrying in 5s...")
        sleep(5)
        M_MID = rednet.lookup(M_PSTATUS, M_MHOST)
    end
    print("[M] Found master: "..M_MID)
end

function register(reset_status)
    io.write("[M] Registering... ")
    rednet.send(M_MID, os.getComputerLabel(), M_PREGISTER)
    local _, msg = rednet.receive(M_PREGISTER, 5)
    if msg ~= nil then
        if reset_status then
            STATUS = msg
        end
        sleep(1)
        rednet.send(M_MID, STATUS, M_PSTATUS)
        print("OK")
    else
        print("FAILED")
    end
    return msg ~= nil
end

function listener()
    print("[I] Ready!")
    while true do
        local id, msg, proto = rednet.receive()
        if proto == M_PREGISTER then
            print("[M] RECV: "..id.."/"..msg.."/"..proto)
            sleep(1)
            register(msg ~= "CHK_REGISTER")
        elseif proto == M_PCOMMAND then
            print("[M] RECV: "..id.."/"..msg.."/"..proto)
            STATUS = msg
        else
            print(id, proto)
        end
    end
end

function work()
    while true do
        if STATUS == "2" then
            redstone.setOutput("front", true)
            turtle.attackDown()
            sleep(ATK_DELAY)
        else
            redstone.setOutput("front", false)
            sleep(2)
        end
    end
end

function time()
    return string.format("%.2f", os.clock() - START_CLK)
end

function main()
    print("[" .. time() .. "] ----- Auto Mob v01b -----")
    print("[M] Computer ID:"..os.getComputerID())
    init()
    if not register(true) then return end

    parallel.waitForAny(work, listener)

end

main()
