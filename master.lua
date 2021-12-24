START_CLK = os.clock()
M_PSTATUS = "PSTATUS"
M_PREGISTER = "PREGISTER"
M_PCOMMAND = "PCOMMAND"
M_MID = os.getComputerID()
monitor = nil
PALETTE = {
    ["-1"] = colors.red,
    ["0"] = colors.yellow,
    ["1"] = colors.white,
    ["2"] = colors.green
}
CLIENTS = {
    tree1 = {id = -1, status = "-1"},
    tree2 = {id = -1, status = "-1"},
    tree3 = {id = -1, status = "-1"},
    tree4 = {id = -1, status = "-1"},
    rice1 = {id = -1, status = "-1"},
    rice2 = {id = -1, status = "-1"},
    ender1 = {id = -1, status = "-1"},
    skeleton1 = {id = -1, status = "-1"}
}

function get_ordered_client_id()
    local ordered = {}
    for label in pairs(CLIENTS) do
        table.insert(ordered, label)
    end
    table.sort(ordered)
    return ordered
end

function init()
    monitor = peripheral.find("monitor")
    rednet.open("left")
    rednet.unhost(M_PSTATUS, os.getComputerLabel())
    rednet.host(M_PSTATUS, os.getComputerLabel())
    rednet.broadcast("CHK_REGISTER", M_PREGISTER)
    monitor_update_client()
end

function monitor_update_client()
    monitor.clear()
    local ordered = get_ordered_client_id()
    for i = 1, #ordered do
        local label, client = ordered[i], CLIENTS[ordered[i]]
        monitor.setCursorPos(1, i)
        monitor.setTextColour(PALETTE[client.status])
        monitor.write(label)
    end
end

function listener()
    while true do
        print("["..os.getComputerID().."] Ready!")
        local id, msg, proto = rednet.receive()
        if proto == M_PREGISTER then
            print("[M] RECV: "..id.."/"..msg.."/"..proto)
            CLIENTS[msg] = {id = id, status = "0"}
            rednet.send(id, "1", M_PREGISTER)
            monitor_update_client()
        elseif proto == M_PSTATUS then
            print("[M] RECV: "..id.."/"..msg.."/"..proto)
            for hostname, client in pairs(CLIENTS) do
                if client.id == id then
                    CLIENTS[hostname].status = msg
                    break
                end
            end
            monitor_update_client()
        else
            print(id, proto)
        end
    end
end

function commander()
    while true do
        local _, _, x, y = os.pullEvent("monitor_touch")
        local ordered = get_ordered_client_id()
        if y <= #ordered then
            local label, client = ordered[y], CLIENTS[ordered[y]]
            if client.status == "1" then
                monitor.setCursorPos(1, y)
                monitor.setTextColour(PALETTE["2"])
                monitor.write(label)
                rednet.send(client.id, "2", M_PCOMMAND)
                CLIENTS[label].status = "2"
            elseif client.status == "2" then
                monitor.setCursorPos(1, y)
                monitor.setTextColour(PALETTE["1"])
                monitor.write(label)
                rednet.send(client.id, "1", M_PCOMMAND)
                CLIENTS[label].status = "1"
            end
        end
    end
end

function time()
    return string.format("%.2f", os.clock() - START_CLK)
end

function main()
    print("[" .. time() .. "] ----- Master v01a -----")
    print("[M] Computer ID:"..os.getComputerID())
    init()
    
    parallel.waitForAny(listener, commander)

end

main()
