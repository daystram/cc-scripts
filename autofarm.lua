SLOT_FUEL, SLOT_PRODUCT, SLOT_SEED, SLOT_COVER = 1, 2, 4, 5
FUEL_TRESHOLD = 400
INTERVAL = 180
INIT = true
START_CLK = os.clock()

function move(action, count)
    count = count or 1  -- defaults param to 1
    local ACT = {
        ["f"] = turtle.forward,
        ["b"] = turtle.back,
        ["u"] = turtle.up,
        ["d"] = turtle.down,
        ["l"] = turtle.turnLeft,
        ["r"] = turtle.turnRight,
    }
    for d = 1, count do
        success = false
        while not success do
            success = ACT[action]()
        end

    end
end

function refuel(qty)
    turtle.select(SLOT_FUEL)
    local fuel = turtle.refuel(qty)
    turtle.select(SLOT_PRODUCT)
    return fuel
end

function clear_inventory()
    io.write("[D] Dumping... ")
    turtle.select(SLOT_PRODUCT)
    for slot = SLOT_PRODUCT, SLOT_COVER - 1 do
        turtle.select(slot)
        while turtle.getItemCount(slot) > 1 do
            turtle.dropDown(1)
        end
    end
    turtle.select(SLOT_PRODUCT)
    print("Done!")
end

function check_fuel()
    io.write("[D] Checking fuel... ")
    if turtle.getFuelLevel() >= FUEL_TRESHOLD then
        io.write("OK (" .. turtle.getFuelLevel() .. ")")
    else
        local old_level = turtle.getFuelLevel()
        while turtle.getFuelLevel() < FUEL_TRESHOLD do
            if not refuel(1) then
                io.write("\n[E] Insert fuel to Slot 1. Press ENTER when done...")
                read()
            end
        end
        io.write("REFUEL (" .. turtle.getFuelLevel() .. " [+" .. turtle.getFuelLevel() - old_level .. "])")
    end
    print("")
end

function check_crops()
    harvested = 0
    io.write("[D] Checking crops... ")
    for col = 1, 9 do
        for row = 1, 9 do
            local has_crop, data = turtle.inspectDown()
            if has_crop then
                if data.name ~= "openblocks:sprinkler" then
                    if data.metadata == 7 then
                        harvested = harvested + 1
                        turtle.placeDown()
                        sleep(0.5)
                    end
                    turtle.suckDown()
                    turtle.suckDown()
                end
            end
            if row ~= 9 then
                -- move("f")
                move("f")
            end
        end
        if col ~= 9 then
            if col % 2 == 1 then
                move("l")
                move("f")
                move("l")
            else
                move("r")
                move("f")
                move("r")
            end
        end
    end
    print("Done! (" .. harvested .. ")")
end

function check_home()
    local has_block, data = turtle.inspectDown()
    if not has_block or data.name ~= "minecraft:chest" then
        print("[E] Bottom chest missing!")
        return false
    end
    return true
end

function move_out()
    move("f")
end

function move_in()
    move("r")
    move("f", 8)
    move("l")
    move("b", 9)
end

function time()
    return string.format("%.2f", os.clock() - START_CLK)
end

function main()
    print("[" .. time() .. "] ----- Auto Farm v01i -----")
    print("[I] Insert fuel into Slot 1!")
    print("[I] Insert 1 product into Slot 2 and 3!")
    print("[I] Insert 1 seed into Slot 4!")
    print("[I] Insert 1 cobble into remaining slot!")
    if not check_home() then
        return
    end
    check_fuel()
    io.write("Press ENTER to start...")
    read()
    INIT = false

    while true do
        print("[" .. time() .. "] ---")
        check_fuel()

        move_out()
        check_crops()
        move_in()
        clear_inventory()
        
        sleep(INTERVAL)
    end
end

main()
