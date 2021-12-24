M_PSTATUS = "PSTATUS"
M_PREGISTER = "PREGISTER"
M_PCOMMAND = "PCOMMAND"
M_MID = nil
M_MHOST = "master"
STATUS = "-1"

function init()
    rednet.open("left")
    rednet.unhost(M_PSTATUS, os.getComputerLabel())
    M_MID = rednet.lookup(M_PSTATUS, M_MHOST)
    if M_MID ~= nil then
        print("[M] Found master: "..M_MID)
    else
        print("[M] Cannot find master!")
    end
    return M_MID ~= nil
end

function register(reset_status)
    io.write("[M] Registering... ")
    rednet.send(M_MID, os.getComputerLabel(), M_PREGISTER)
    local _, msg = rednet.receive(M_PREGISTER, 5)
    if msg ~= nil then
        if reset_status then
            STATUS = msg
            print(STATUS)
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
    while true do
        print("["..os.getComputerID().."] Ready!")
        local id, msg, proto = rednet.receive()
        if proto == M_PREGISTER then
            print("RECV: "..id.."/"..msg.."/"..proto)
            sleep(1)
            register(msg ~= "CHK_REGISTER")
        elseif proto == M_PCOMMAND then
            print("RECV: "..id.."/"..msg.."/"..proto)
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
            sleep(0.5)
            redstone.setOutput("front", false)
            sleep(0.5)
        else
            sleep(1)
        end
    end
end

function main()
    print("["..os.getComputerID().."]")
    init()
    if not register(true) then
        return
    end

    parallel.waitForAny(work, listener)

end

main()
