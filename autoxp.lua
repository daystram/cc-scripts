SLOT_FUEL, SLOT_CACTUS, SLOT_COAL = 1, 2, 2
FUEL_TRESHOLD = 200
START_CLK = os.clock()

MODE_CACTUS = "cactus"
MODE_COAL = "coal"
MODE = "" -- select one: [MODE_CACTUS, MODE_COAL]

function time()
    return string.format("%.2f", os.clock() - START_CLK)
end

function refuel(qty)
    turtle.select(SLOT_FUEL)
    local fuel = turtle.refuel(qty)
    return fuel
end

function check_fuel()
    io.write("[D] Checking fuel... ")
    if turtle.getFuelLevel() >= FUEL_TRESHOLD then
        io.write("OK (" .. turtle.getFuelLevel() .. ")")
    else
        local old_level = turtle.getFuelLevel()
        while turtle.getFuelLevel() < FUEL_TRESHOLD do
            if not refuel(1) then
                if MODE == MODE_CACTUS then
                    turtle.turnRight()
                    turtle.select(SLOT_FUEL)
                    turtle.suck(64 - turtle.getItemCount(SLOT_FUEL))
                    turtle.turnLeft()
                end
                if MODE == MODE_COAL then
                    turtle.select(SLOT_FUEL)
                    turtle.suckUp(64 - turtle.getItemCount(SLOT_FUEL))
                end
            end
        end
        io.write("REFUEL (" .. turtle.getFuelLevel() .. " [+" .. turtle.getFuelLevel() - old_level .. "])")
    end
    print("")
end

function fill_cactus()
    turtle.select(SLOT_CACTUS)
    turtle.suckUp(64 - turtle.getItemCount(SLOT_CACTUS))
    local dist = 0
    turtle.forward()
    local has_block, data = turtle.inspectDown()
    while has_block and data.name == "minecraft:furnace" do
        turtle.dropDown(4)
        turtle.forward()
        dist = dist + 1
        has_block, data = turtle.inspectDown()
    end
    for i = 1, dist do
        turtle.back()
    end
    turtle.back()
end

function fill_coal()
    turtle.select(SLOT_COAL)
    turtle.suckUp(64 - turtle.getItemCount(SLOT_COAL))
    local dist = 0
    turtle.forward()
    turtle.turnLeft()
    local has_block, data = turtle.inspect()
    while has_block and data.name == "minecraft:furnace" do
        turtle.drop(16)
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        dist = dist + 1
        has_block, data = turtle.inspect()
    end
    turtle.turnRight()
    for i = 1, dist do
        turtle.back()
    end
    turtle.back()
end

function main()
    print("[" .. time() .. "] ----- Auto XP v01b -----")
    if MODE == "" then
        print("[E] Select mode!")
        return
    end
    check_fuel()
    io.write("Press ENTER to start...")
    read()

    while true do
        print("[" .. time() .. "] ---")
        check_fuel()

        if MODE == MODE_CACTUS then
            fill_cactus()
        end
        if MODE == MODE_COAL then
            fill_coal()
        end
        
        sleep(10)
    end
end

main()
