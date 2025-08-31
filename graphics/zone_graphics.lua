local ZoneGraphics = {}

function ZoneGraphics.drawBase(zone)
    local color = (zone.getDisplayColor and zone:getDisplayColor()) or zone.color
    
    -- Dim inactive zones
    local alpha = zone.active and 1.0 or 0.3
    
    love.graphics.setColor(color[1] * 0.3 * alpha, color[2] * 0.3 * alpha, color[3] * 0.3 * alpha)
    love.graphics.rectangle("fill", zone.x, zone.y, zone.width, zone.height)
    
    love.graphics.setColor(color[1] * alpha, color[2] * alpha, color[3] * alpha)
    love.graphics.rectangle("line", zone.x, zone.y, zone.width, zone.height)
    
    if zone.progress > 0 and not zone.completed then
        local progress_width = (zone.progress / zone.cost) * zone.width
        love.graphics.setColor(color[1] * alpha, color[2] * alpha, color[3] * alpha, 0.7)
        love.graphics.rectangle("fill", zone.x, zone.y, progress_width, zone.height)
    end
    
    love.graphics.setColor(1 * alpha, 1 * alpha, 1 * alpha)
    local label = (zone.getDisplayLabel and zone:getDisplayLabel()) or zone.label
    love.graphics.print(label, zone.x + 5, zone.y + 5)
    love.graphics.print(string.format("%.1f/%.0f", zone.progress, zone.cost), zone.x + 5, zone.y + 20)
    
    if not zone.active then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("INACTIVE", zone.x + 5, zone.y + 35)
    end
    
    if not zone.active_for_bots then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("BOTS OFF", zone.x + 5, zone.y + 50)
    end
    
    if zone.completed then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("BUILT!", zone.x + zone.width/2 - 20, zone.y + zone.height/2)
    end
end

function ZoneGraphics.drawMineExtra(mine_zone)
    if mine_zone.progress > 0 and not mine_zone.completed then
        love.graphics.setColor(1, 1, 0, 0.7)
        love.graphics.print("WORKING...", mine_zone.x + 5, mine_zone.y + 35)
    end
end

function ZoneGraphics.drawUpgradeExtra(upgrade_zone)
    local mode = upgrade_zone:getCurrentMode()
    local info
    if mode == "capacity" then
        info = string.format("+%.0f capacity", upgrade_zone.capacity_upgrade)
    elseif mode == "speed" then
        info = string.format("+%.0f speed", upgrade_zone.speed_upgrade)
    elseif mode == "range" then
        info = string.format("+%.0f range", upgrade_zone.range_upgrade)
    end
    if info then
        love.graphics.setColor(1,1,1)
        love.graphics.print(info, upgrade_zone.x + 5, upgrade_zone.y + 35)
    end
end

return ZoneGraphics