SLOT_FUEL, SLOT_SAPLING, SLOT_FERTILIZER, SLOT_LOG = 1, 2, 3, 4
FUEL_TRESHOLD = 400 
init = true
START_CLK = os.clock()

BLOCK_ID_LOG = "minecraft:jungle_log"
BLOCK_ID_SAPLING = "minecraft:jungle_sapling"

function refuel(qty)
    turtle.select(SLOT_FUEL)
    local fuel = turtle.refuel(qty)
    turtle.select(SLOT_LOG)
    return fuel
end

function chop_tree()
    turtle.select(SLOT_LOG)
    local height = 0
    turtle.dig()
    turtle.forward()
    turtle.dig()
    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
        turtle.dig()
        height = height + 1
    end
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.turnRight()
    turtle.dig()
    while height > 0 do
        turtle.digDown()
        turtle.down()
        turtle.dig()
        height = height - 1
    end
    turtle.turnLeft()
    turtle.back()
    turtle.turnRight()
    turtle.back()
    turtle.select(SLOT_LOG)
end

function plant_tree()
    if turtle.getItemCount(SLOT_SAPLING) >= 4 then
        turtle.select(SLOT_SAPLING)
        turtle.forward()
        turtle.forward()
        turtle.turnLeft()
        turtle.place()
        turtle.turnRight()
        turtle.back()
        turtle.place()
        turtle.turnLeft()
        turtle.place()
        turtle.turnRight()
        turtle.back()
        turtle.place()
        turtle.select(SLOT_LOG)
        return true
    end
    return false
end

function clear_inventory()
    turtle.select(SLOT_LOG)
    for slot = SLOT_LOG + 1, 16 do
        turtle.select(slot)
        turtle.dropDown()
    end
    turtle.select(SLOT_LOG)
end

function check_fuel()
    io.write("[D] Checking fuel... ")
    if turtle.getFuelLevel() >= FUEL_TRESHOLD then
        io.write("OK (" .. turtle.getFuelLevel() .. ")")
    else
        local old_level = turtle.getFuelLevel()
        while turtle.getFuelLevel() < FUEL_TRESHOLD do
            if init then
                if not refuel(1) then
                    io.write("\n[E] Insert fuel to Slot 1. Press ENTER when done...")
                    read()
                end
            else
                if turtle.getItemCount(SLOT_FUEL) <= 4 then
                    io.write("\n[D] Making 8 charcoals... ")
                    make_charcoal(8)
                    io.write("Done!")
                else
                    refuel(1)
                end
            end
        end
        io.write("REFUEL (" .. turtle.getFuelLevel() .. " [+" .. turtle.getFuelLevel() - old_level .. "])")
    end
    print("")
end

function check_sapling()
    if turtle.getItemCount(SLOT_SAPLING) < 4 then
        io.write("\n[D] Collecting saplings... ")
        turtle.turnLeft()
        turtle.select(SLOT_SAPLING)
        turtle.suck()
        turtle.select(SLOT_LOG)
        turtle.turnRight()
        io.write("Done!")
    end
    turtle.select(SLOT_LOG)
    for slot = SLOT_SAPLING + 1, 16 do
        turtle.select(slot)
        if turtle.getItemCount() > 0 and turtle.getItemDetail().name == BLOCK_ID_SAPLING then
            turtle.dropDown()
        end
    end
    turtle.select(SLOT_LOG)
end

function check_tree()
    io.write("[D] Checking tree... ")
    local has_block, data = turtle.inspect()
    if has_block then
        if data.name == BLOCK_ID_LOG then
            chop_tree()BLOCK_ID_SAPLING = "minecraft:"
            io.write("CUT ")
            if plant_tree() then io.write("PLANT") else io.write("NOSAP") end
        elseif data.name == "minecraft:sapling" then
            io.write("OK")
        else
            io.write("ERR (unexpected block: " .. data.name .. ")")
        end
    else
        if plant_tree() then io.write("PLANT") else io.write("NOSAP") end
    end
    print("")
end

function check_home()
    local has_block, data = turtle.inspectUp()
    if not has_block or data.name ~= "minecraft:furnace" then
        print("[E] Top furnace missing!")
        return false
    end
    turtle.turnLeft()
    has_block, data = turtle.inspect()
    turtle.turnRight()
    if not has_block or data.name ~= "minecraft:chest" then
        print("[E] Left chest missing!")
        return false
    end
    return true
end

-- move_out() moves the turtle right beside the bottom of the tree log or sapling
function move_out()
    local has_block, data = turtle.inspect()
    while !has_block or not (data.name == BLOCK_ID_LOG or data.name == BLOCK_ID_SAPLING) do
        turtle.dig()
        turtle.forward()
        has_block, data = turtle.inspectDown()
        if has_block and data.name == "minecraft:dirt" then
            turtle.back()
            break
        end
        has_block, data = turtle.inspect()
    end
end

-- move_in() moves the turtle back home
function move_in()
    local has_block, data = turtle.inspectUp()
    while !has_block or data.name ~= "minecraft:furnace" do
        turtle.back()
        has_block, data = turtle.inspect()
    end
end

function make_charcoal(qty)
    turtle.select(SLOT_FUEL)
    turtle.dropUp(math.ceil(qty / 8))
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.digUp()
    turtle.up()
    turtle.digUp()
    turtle.up()
    turtle.dig()
    turtle.forward()
    turtle.select(SLOT_LOG)
    turtle.dropDown(qty)
    turtle.back()
    turtle.digDown()
    turtle.down()
    turtle.digDown()
    turtle.down()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    turtle.turnLeft()
    sleep(80 * math.ceil(qty / 8))
    turtle.select(SLOT_FUEL)
    turtle.suckUp()
    turtle.select(SLOT_LOG)
end

function time()
    return string.format("%.2f", os.clock() - START_CLK)
end

function main()
    print("[" .. time() .. "] ----- Auto Tree v04a -----")
    print("[I] Insert fuel into Slot 1!")
    print("[I] Insert sapling into left chest!")
    if not check_home() then
        return
    end
    check_fuel()
    check_sapling()
    io.write("Press ENTER to start...")
    read()
    init = false

    while true do
        print("[" .. time() .. "] ---")
        check_fuel()
        check_sapling()

        move_out()
        check_tree()
        move_in()
        clear_inventory()
        
        sleep(60)
    end
end

main()
