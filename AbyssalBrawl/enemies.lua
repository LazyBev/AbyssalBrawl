-- enemies.lua

enemies = {}

function enemies.drawJellyfish (x, y, animState, color)
    local time = love.timer.getTime()
    local baseColor = color or {0.8, 0.5, 0.6, 0.7} -- Slightly translucent by default
    
    -- Create dynamic transparency based on depth simulation
    local depthAlpha = 0.7 + math.sin(time * 0.3) * 0.1
    
    -- Multiple translucent bell layers for volumetric effect
    local bellRadius = 18
    local bellHeight = 20 -- Height of the bell to make it more dome-like
    local pulse = math.sin(time * 1.8) * 2.5
    if animState == 1 then pulse = math.sin(time * 6) * 3.5
    elseif animState == 2 then pulse = math.sin(time * 9) * 4.5 end
    
    -- Dynamic animation based on movement state
    local bellExpansion = 1.0 + pulse * 0.05
    
    -- Draw multiple translucent layers for volumetric effect (outer to inner)
    for layer = 1, 4 do
        local layerPoints = {}
        local layerRadius = bellRadius * (1 - (layer-1) * 0.15) * bellExpansion
        local layerHeight = bellHeight * (1 - (layer-1) * 0.12) * bellExpansion
        
        for angle = 0, math.pi * 2, 0.05 do
            -- Add subtle irregularity for organic look
            local radiusVar = 1 + math.sin(angle * 7 + time) * 0.04
            local bx = x + math.cos(angle) * layerRadius * radiusVar + pulse * (1 - (layer-1) * 0.2)
            local by = y + math.sin(angle) * layerHeight * radiusVar + pulse * 0.6 * (1 - (layer-1) * 0.2)
            table.insert(layerPoints, bx)
            table.insert(layerPoints, by)
        end
        
        -- Gradient coloring for each layer
        local alpha = baseColor[4] * (0.7 - (layer-1) * 0.15) * depthAlpha
        local saturation = 1 - (layer-1) * 0.1
        love.graphics.setColor(baseColor[1] * saturation, baseColor[2] * saturation, baseColor[3] * saturation, alpha)
        love.graphics.polygon("fill", layerPoints)
    end
    
    -- Internal organs/structures visible through translucent bell
    love.graphics.setColor(baseColor[1] * 1.1, baseColor[2] * 0.9, baseColor[3] * 1.2, baseColor[4] * 0.5)
    local innerStructurePoints = {}
    for angle = 0, math.pi * 2, 0.2 do
        local ix = x + math.cos(angle) * (bellRadius * 0.4) * (1 + math.sin(time * 1.5) * 0.05)
        local iy = y + math.sin(angle) * (bellHeight * 0.5) * (1 + math.sin(time * 1.5) * 0.05)
        table.insert(innerStructurePoints, ix)
        table.insert(innerStructurePoints, iy)
    end
    love.graphics.polygon("fill", innerStructurePoints)
    
    -- Oral arms
    local oralArmCount = 4
    for i = 1, oralArmCount do
        local angle = (i / oralArmCount) * math.pi * 2 + time * 0.2
        local baseX = x + math.cos(angle) * (bellRadius * 0.3)
        local baseY = y + bellHeight * 0.5
        
        local oralArmPoints = {baseX, baseY}
        local segCount = 12
        for t = 1, segCount do
            local segment = t / segCount
            local wave = math.sin(time * 1.5 + i + segment * 5) * (1 - segment * 0.7) * 5
            local tx = baseX + wave + math.cos(angle + segment) * (segment * 3)
            local ty = baseY + segment * 30
            table.insert(oralArmPoints, tx)
            table.insert(oralArmPoints, ty)
        end
        
        -- Draw frilly, ribbon-like oral arms with translucency
        love.graphics.setColor(baseColor[1] * 1.1, baseColor[2] * 1.1, baseColor[3] * 1.3, baseColor[4] * 0.6)
        love.graphics.setLineWidth(3.5 - (i % 2))
        love.graphics.line(oralArmPoints)
        
        -- Add frills to oral arms
        for j = 2, #oralArmPoints/2 - 1, 2 do
            if j % 2 == 0 then
                local cx, cy = oralArmPoints[j*2-1], oralArmPoints[j*2]
                local nx, ny = oralArmPoints[j*2+1], oralArmPoints[j*2+2]
                local angle = math.atan2(ny - cy, nx - cx) + math.pi/2
                local frillSize = 3 * (1 - j/(#oralArmPoints/2))
                love.graphics.setColor(baseColor[1] * 1.2, baseColor[2] * 1.2, baseColor[3] * 1.4, baseColor[4] * 0.4)
                love.graphics.line(
                    cx, cy,
                    cx + math.cos(angle) * frillSize * math.sin(time * 2 + j),
                    cy + math.sin(angle) * frillSize * math.sin(time * 2 + j)
                )
            end
        end
    end
    
    -- Tentacles: Segmented with more organic movement
    local tentacleCount = 28 -- More tentacles for realism
    local tentacleLength = 45 -- Define length here for reuse
    for i = 1, tentacleCount do
        local angle = (i / tentacleCount) * math.pi * 2 -- Full circle for tentacle placement
        -- Distribute tentacles around bell edge
        local radiusVar = 1 + math.sin(i * 7.3) * 0.08 -- Slight variation in placement
        local baseX = x + math.cos(angle) * (bellRadius * radiusVar + pulse * 0.8)
        local baseY = y + math.sin(angle) * (bellHeight * radiusVar + pulse * 0.5)
        
        -- Tentacle properties
        local tentaclePoints = {baseX, baseY}
        local thickness = 1.2 + (i % 3) * 0.2
        local length = tentacleLength * (0.7 + (i % 5) * 0.1) -- Varied lengths
        local segments = 15
        
        -- Build each tentacle as a series of segments with organic movement
        for t = 1, segments do
            local segment = t / segments
            -- Complex wave pattern for more organic movement
            local primaryWave = math.sin(time * 2 + i * 0.5 + segment * 3) * (1 - segment * 0.3) * 4
            local secondaryWave = math.cos(time * 3 + i * 0.7 + segment * 2) * (1 - segment * 0.5) * 2
            local tx = baseX + primaryWave + secondaryWave
            local ty = baseY + segment * length
            
            if animState == 1 then
                tx = tx + math.sin(time * 8 + i + segment * 5) * segment * 2
            end
            
            table.insert(tentaclePoints, tx)
            table.insert(tentaclePoints, ty)
        end
        
        -- Draw tentacle with gradient and slightly varied opacity
        local tentacleAlpha = baseColor[4] * (0.8 - (i % 3) * 0.1) * depthAlpha
        love.graphics.setColor(baseColor[1] * 0.9, baseColor[2] * 0.9, baseColor[3] * 1.1, tentacleAlpha)
        love.graphics.setLineWidth(thickness * (1.2 - pulse * 0.02))
        love.graphics.line(tentaclePoints)
        
        -- Add nematocysts (stinging cells) along tentacles
        if i % 3 == 0 then
            for j = 3, #tentaclePoints/2, 2 do
                local nx = tentaclePoints[j*2-1]
                local ny = tentaclePoints[j*2]
                love.graphics.setColor(1, 1, 1, 0.7 * (1 - j/(#tentaclePoints)))
                love.graphics.circle("fill", nx, ny, 0.5)
            end
        end
    end
    
    -- Advanced bioluminescence with particle system effect
    local glowCount = animState == 1 and 15 or 8
    for i = 1, glowCount do
        -- Deeper colors for inner glow
        local pulseFactor = 0.5 + math.sin(time * 1.2 + i) * 0.5
        love.graphics.setColor(0.7, 0.8, 1.0, 0.3 * pulseFactor)
        local px = x + math.cos(time * 0.7 + i * 1.1) * bellRadius * 0.7
        local py = y + math.sin(time * 0.5 + i * 0.9) * bellHeight * 0.7
        love.graphics.circle("fill", px, py, 2 + pulseFactor)
        
        -- Outer glow halo
        love.graphics.setColor(0.7, 0.8, 1.0, 0.15 * pulseFactor)
        love.graphics.circle("fill", px, py, 3 + pulseFactor * 2)
    end
        
    -- Water distortion effect around jellyfish
    if animState > 0 then
        love.graphics.setColor(1, 1, 1, 0.03)
        for i = 1, 3 do
            love.graphics.circle("line", x, y, bellRadius * (1.2 + i * 0.2 + math.sin(time * 3) * 0.05))
        end
    end
        
    love.graphics.setLineWidth(1) -- Reset line width
end
    
function enemies.drawAngler (x, y, animState, color)
    local time = love.timer.getTime()
    local baseColor = color or {0.2, 0.3, 0.1, 0.9} -- Dark greenish-brown, slightly translucent
    
    local swim = math.sin(time * 1.2) * 2.5 -- Subtle swimming motion
    local secondarySwim = math.cos(time * 1.8) * 1.2 -- Secondary motion
    if animState == 1 then 
        swim = math.sin(time * 5) * 4
        secondarySwim = math.cos(time * 4.2) * 2.5
    elseif animState == 2 then 
        swim = math.sin(time * 8) * 3
        secondarySwim = math.cos(time * 6.5) * 1.8
    end
    
    -- Body: Non-uniform shape with textured surface for deep-sea realism
    local bodyRadius = 22 -- Base size of the body
    local bodyPoints = {}
    
    -- Create irregular body shape
    for angle = 0, math.pi * 2, 0.1 do
        -- Add organic irregularity to shape
        local radiusVar = 1 + math.sin(angle * 8 + time * 0.5) * 0.08 + math.cos(angle * 5 - time * 0.3) * 0.06
        local bx = x + math.cos(angle) * bodyRadius * radiusVar + math.sin(angle * 3) * swim * 0.3
        local by = y + swim + math.sin(angle) * bodyRadius * 0.9 * radiusVar + math.cos(angle * 2) * secondarySwim * 0.2
        table.insert(bodyPoints, bx)
        table.insert(bodyPoints, by)
    end
    
    -- Draw body with gradient fill
    local gradient = {}
    for i = 1, 5 do
        local factor = 1 - (i-1) * 0.15
        table.insert(gradient, {
            baseColor[1] * factor, 
            baseColor[2] * factor, 
            baseColor[3] * factor, 
            baseColor[4]
        })
    end
    
    love.graphics.setColor(gradient[1][1], gradient[1][2], gradient[1][3], gradient[1][4])
    love.graphics.polygon("fill", bodyPoints)
    
    -- Multiple layers for depth and shading effect
    love.graphics.setColor(gradient[2][1], gradient[2][2], gradient[2][3], gradient[2][4] * 0.7)
    local innerBodyPoints = {}
    for angle = 0, math.pi * 2, 0.15 do
        local radiusVar = 1 + math.sin(angle * 7 + time * 0.4) * 0.05
        local bx = x + math.cos(angle) * bodyRadius * 0.85 * radiusVar + swim * 0.2
        local by = y + swim + math.sin(angle) * bodyRadius * 0.8 * radiusVar
        table.insert(innerBodyPoints, bx)
        table.insert(innerBodyPoints, by)
    end
    love.graphics.polygon("fill", innerBodyPoints)
    
    -- Detailed skin texture: Realistic bumps, scales, and pores
    love.graphics.setColor(gradient[3][1], gradient[3][2], gradient[3][3], gradient[3][4] * 0.6)
    for i = 1, 15 do
        local angle = i * 0.42
        local distance = bodyRadius * (0.4 + math.sin(i * 3.7) * 0.3)
        local tx = x + math.cos(angle) * distance + swim * 0.15
        local ty = y + swim + math.sin(angle) * distance
        local scale = 1.5 + math.sin(time + i) * 0.8
        -- Various skin features with different sizes
        love.graphics.circle("fill", tx, ty, scale * (0.8 + (i % 3) * 0.4))
        
        -- Add tiny light-sensitive spots (photophores)
        if i % 4 == 0 then
            love.graphics.setColor(0.6, 0.7, 0.5, 0.5)
            love.graphics.circle("fill", tx + 2, ty + 1, 0.8)
            love.graphics.setColor(gradient[3][1], gradient[3][2], gradient[3][3], gradient[3][4] * 0.6)
        end
    end
    
    -- Fins: Multiple with realistic movement patterns
    local finPoints = {}
    -- Dorsal fin
    love.graphics.setColor(gradient[2][1], gradient[2][2], gradient[2][3], gradient[2][4] * 0.8)
    finPoints = {
        x - 5, y - bodyRadius * 0.8 + swim,
        x + 5, y - bodyRadius * 0.9 + swim,
        x + 15, y - bodyRadius * 0.1 + swim + math.sin(time * 2) * 2,
        x + 8, y + 2 + swim,
        x - 8, y + 2 + swim,
        x - 15, y - bodyRadius * 0.1 + swim + math.sin(time * 2.3) * 1.5
    }
    love.graphics.polygon("fill", finPoints)
    
    -- Pectoral fins
    finPoints = {
        x - bodyRadius * 0.8, y + swim,
        x - bodyRadius * 1.2, y - 5 + swim + math.sin(time * 2.5) * 3,
        x - bodyRadius * 1.4, y + 2 + swim + math.sin(time * 2.2) * 2,
        x - bodyRadius * 0.9, y + 8 + swim
    }
    love.graphics.polygon("fill", finPoints)
    
    -- Other side
    finPoints = {
        x + bodyRadius * 0.8, y + swim,
        x + bodyRadius * 1.2, y - 5 + swim + math.sin(time * 2.5) * 3,
        x + bodyRadius * 1.4, y + 2 + swim + math.sin(time * 2.2) * 2,
        x + bodyRadius * 0.9, y + 8 + swim
    }
    love.graphics.polygon("fill", finPoints)
    
    -- Jaw
    local jawPoints = {}
    local jawWidth = 16 -- Wider jaw
    local jawHeight = 14 -- Deeper jaw
    local mouthOpeningFactor = 6 -- Constant open mouth (increase for wider opening)
    if animState == 1 then mouthOpeningFactor = 8 -- More aggressive open
    elseif animState == 2 then mouthOpeningFactor = 10 end
    
    -- Draw upper jaw with more organic shape
    local upperJawPoints = {}
    for angle = -math.pi, 0, 0.08 do
        local jawVariation = 1 + math.sin(angle * 8) * 0.1 -- Subtle irregularity
        local jx = x + math.cos(angle) * jawWidth * jawVariation
        local jy = y + bodyRadius * 0.8 + swim + math.sin(angle) * jawHeight * jawVariation
        if angle > -0.3 and angle < 0.3 then -- Create deeper middle part
            jy = jy + 2
        end
        table.insert(upperJawPoints, jx)
        table.insert(upperJawPoints, jy)
    end
    
    -- Draw upper jaw
    love.graphics.setColor(gradient[3][1] * 0.7, gradient[3][2] * 0.7, gradient[3][3] * 0.7, gradient[3][4])
    love.graphics.polygon("fill", upperJawPoints)
    
    -- Draw lower jaw with more opening
    local lowerJawPoints = {}
    -- Bottom jaw starts with connection to body
    table.insert(lowerJawPoints, x - jawWidth, y + bodyRadius * 0.8 + swim)
    -- Create curved shape for lower jaw
    for angle = -math.pi, 0, 0.08 do
        local jawVariation = 1 + math.sin(angle * 8) * 0.1
        local jx = x + math.cos(angle) * jawWidth * jawVariation
        local jy = y + bodyRadius * 0.8 + swim + math.sin(angle) * jawHeight * jawVariation + mouthOpeningFactor
        table.insert(lowerJawPoints, jx)
        table.insert(lowerJawPoints, jy)
    end
    
    -- Add the bottom points to create sharp end
    local bottomJawY = y + bodyRadius * 0.8 + swim + jawHeight + mouthOpeningFactor
    table.insert(lowerJawPoints, x + jawWidth * 0.3, bottomJawY + 2)
    table.insert(lowerJawPoints, x, bottomJawY + 4)
    table.insert(lowerJawPoints, x - jawWidth * 0.3, bottomJawY + 2)
    
    -- Draw lower jaw
    love.graphics.setColor(gradient[3][1] * 0.7, gradient[3][2] * 0.7, gradient[3][3] * 0.7, gradient[3][4])
    love.graphics.polygon("fill", lowerJawPoints)
    
    -- Inner mouth - darker color
    love.graphics.setColor(gradient[4][1] * 0.4, gradient[4][2] * 0.4, gradient[4][3] * 0.4, gradient[4][4])
    love.graphics.circle("fill", x, y + bodyRadius * 0.8 + swim + mouthOpeningFactor/2, jawWidth * 0.8)
    
    -- Teeth: Positioned INSIDE the mouth cavity
    love.graphics.setColor(0.9, 0.9, 0.8, 0.85)
    
    -- Upper jaw teeth - pointing downward into mouth
    for i = -jawWidth + 2, jawWidth - 2, 3 do
        local toothSize = 2.5 + math.sin(i * 0.8) * 0.8
        local tx = x + i
        local ty = y + bodyRadius * 0.8 + swim + 2 -- At upper jaw edge
        love.graphics.polygon("fill", 
            tx, ty, 
            tx - toothSize * 0.6, ty + toothSize * 1.5, 
            tx + toothSize * 0.6, ty + toothSize * 1.5
        )
    end
    
    -- Lower jaw teeth - pointing upward from lower jaw
    for i = -jawWidth + 4, jawWidth - 4, 4 do
        local toothSize = 3 + math.cos(i * 0.7) * 1.2
        local tx = x + i
        local ty = bottomJawY - 2 -- At lower jaw edge
        love.graphics.polygon("fill", 
            tx, ty, 
            tx - toothSize * 0.7, ty - toothSize * 1.8, 
            tx + toothSize * 0.7, ty - toothSize * 1.8
        )
    end
    
    -- Secondary row of smaller teeth (inner row) on both jaws
    love.graphics.setColor(0.85, 0.85, 0.75, 0.7)
    -- Upper inner teeth
    for i = -jawWidth + 5, jawWidth - 5, 4 do
        local toothSize = 1.8 + math.sin(i * 1.2) * 0.5
        local tx = x + i
        local ty = y + bodyRadius * 0.8 + swim + 5
        love.graphics.polygon("fill", 
            tx, ty, 
            tx - toothSize * 0.5, ty + toothSize * 1.2, 
            tx + toothSize * 0.5, ty + toothSize * 1.2
        )
    end
    
    -- Lower inner teeth
    for i = -jawWidth + 3, jawWidth - 3, 4 do
        local toothSize = 1.5 + math.cos(i * 0.9) * 0.6
        local tx = x + i
        local ty = bottomJawY - 6 -- Positioned inside lower jaw
        love.graphics.polygon("fill", 
            tx, ty, 
            tx - toothSize * 0.5, ty - toothSize * 1.2, 
            tx + toothSize * 0.5, ty - toothSize * 1.2
        )
    end
    
    -- Eyes: Realistic with complex structure
    local eyeSize = 8
    -- Left eye
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9) -- Dark eye surround
    love.graphics.circle("fill", x - bodyRadius * 0.6, y - bodyRadius * 0.2 + swim, eyeSize)
    
    love.graphics.setColor(0.7, 0.7, 0.6, 0.9) -- Eye white
    love.graphics.circle("fill", x - bodyRadius * 0.6, y - bodyRadius * 0.2 + swim, eyeSize * 0.8)
    
    love.graphics.setColor(0.1, 0.1, 0.1, 1) -- Pupil
    love.graphics.circle("fill", x - bodyRadius * 0.6, y - bodyRadius * 0.2 + swim, eyeSize * 0.4 + (animState > 0 and math.sin(time * 5) * eyeSize * 0.1 or 0))
    
    love.graphics.setColor(1, 1, 1, 0.8) -- Highlight
    love.graphics.circle("fill", x - bodyRadius * 0.65, y - bodyRadius * 0.25 + swim, eyeSize * 0.15)
    
    -- Right eye (slightly different)
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.circle("fill", x + bodyRadius * 0.6, y - bodyRadius * 0.2 + swim, eyeSize * 0.9) -- Slightly smaller
    
    love.graphics.setColor(0.7, 0.7, 0.6, 0.9)
    love.graphics.circle("fill", x + bodyRadius * 0.6, y - bodyRadius * 0.2 + swim, eyeSize * 0.7)
    
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.circle("fill", x + bodyRadius * 0.6, y - bodyRadius * 0.2 + swim, eyeSize * 0.35 + (animState > 0 and math.sin(time * 5) * eyeSize * 0.1 or 0))
    
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", x + bodyRadius * 0.65, y - bodyRadius * 0.25 + swim, eyeSize * 0.12)
    
    -- Lure: Complex with multiple light elements and dynamic movement
    local lureRodLength = bodyRadius * 1.2
    local lureBaseX = x
    local lureBaseY = y - bodyRadius + swim
    local lureEndX = lureBaseX + math.sin(time * 1.5) * 5
    local lureEndY = lureBaseY - lureRodLength + math.cos(time * 2) * 6
    
    -- Draw the illicium (rod) with segments for flexibility
    love.graphics.setColor(0.25, 0.2, 0.15, 0.95)
    local segments = 8
    local prevX, prevY = lureBaseX, lureBaseY
    for i = 1, segments do
        local t = i / segments
        local segX = lureBaseX * (1-t) + lureEndX * t + math.sin(time * 2 + i * 0.5) * 2 * t
        local segY = lureBaseY * (1-t) + lureEndY * t + math.cos(time * 1.7 + i * 0.4) * 2 * t
        love.graphics.setLineWidth(2 * (1 - t * 0.3))
        love.graphics.line(prevX, prevY, segX, segY)
        prevX, prevY = segX, segY
    end
    
    -- Esca (light organ) with complex bioluminescent pattern
    love.graphics.setColor(0.6, 0.5, 0.4, 0.9)
    local escaSize = 6 + (animState > 0 and math.sin(time * 4) * 1 or math.sin(time * 2) * 0.8)
    love.graphics.circle("fill", lureEndX, lureEndY, escaSize)
    
    -- Add texture to esca
    love.graphics.setColor(0.7, 0.6, 0.5, 0.7)
    for i = 1, 5 do
        local angle = i * math.pi * 2 / 5
        local radius = escaSize * 0.6
        love.graphics.circle("fill", 
            lureEndX + math.cos(angle) * radius, 
            lureEndY + math.sin(angle) * radius, 
            escaSize * 0.25
        )
    end
    
    -- Primary bioluminescent glow (pulsing)
    local glowIntensity = 0.8 + math.sin(time * 3) * 0.2
    if animState > 0 then glowIntensity = 0.9 + math.sin(time * 8) * 0.3 end
    
    love.graphics.setColor(1.0, 0.9, 0.5, glowIntensity)
    love.graphics.circle("fill", lureEndX, lureEndY, escaSize * 0.7)
    
    -- Multiple glow halos
    for i = 1, 3 do
        love.graphics.setColor(1.0, 0.9, 0.5, glowIntensity * (0.4 - i * 0.1))
        love.graphics.circle("fill", lureEndX, lureEndY, escaSize * (1 + i * 0.5))
    end
    
    -- Additional photophores (light organs) on body
    if animState > 0 then
        for i = 1, 8 do
            local px = x + math.cos(i * math.pi / 4) * bodyRadius * 0.7
            local py = y + swim + math.sin(i * math.pi / 4) * bodyRadius * 0.7
            local photSize = 1.2 + math.sin(time * 4 + i) * 0.5
            
            -- Inner glow
            love.graphics.setColor(0.9, 0.8, 0.4, 0.6 * math.sin(time * 3 + i))
            love.graphics.circle("fill", px, py, photSize)
            
            -- Outer glow
            love.graphics.setColor(0.9, 0.8, 0.4, 0.2 * math.sin(time * 3 + i))
            love.graphics.circle("fill", px, py, photSize * 2)
        end
    end
    
    -- Water distortion/current effects
    if animState > 0 then
        love.graphics.setColor(1, 1, 1, 0.04)
        for i = 1, 3 do
            love.graphics.circle("line", x, y + swim, bodyRadius * (1.5 + i * 0.3) + math.sin(time * 3 + i) * 2)
        end
    end
    
    love.graphics.setLineWidth(1)
end
    
function enemies.drawSquid (x, y, animState, color)
    local time = love.timer.getTime()
    local baseColor = color or {0.6, 0.3, 0.2, 1}
    
    -- Create realistic body shape with gradient coloring
    local mantleWidth = 36
    local mantleHeight = 50
    local mantlePoints = {}
    local segments = 20
    local thrust = math.sin(time * 1.5) * 4
    
    if animState == 1 then 
        thrust = math.sin(time * 5) * 6
    elseif animState == 2 then 
        thrust = math.sin(time * 8) * 5 
    end
    
    -- Create smooth curved mantle with more points
    for i = 0, segments do
        local angle = (math.pi * i) / segments
        local pointX = x + math.cos(angle) * mantleWidth * (1 + math.sin(angle * 4) * 0.1)
        local pointY = y - mantleHeight * math.sin(angle) + thrust * math.sin(angle)
        table.insert(mantlePoints, pointX)
        table.insert(mantlePoints, pointY)
    end
    
    -- Detailed gradient mantle with subtle texture
    love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], baseColor[4])
    love.graphics.polygon("fill", mantlePoints)
    
    -- Add chromatophores (color-changing cells) effect with small spots
    for i = 1, 30 do
        local spotX = x + math.cos(i * 0.7) * mantleWidth * 0.8 * math.random(0.7, 1)
        local spotY = y + math.sin(i * 0.7) * mantleHeight * 0.7 * math.random(0.7, 1)
        local spotSize = 1.5 * math.random(0.7, 1.3)
        local spotColor = {
            baseColor[1] * (0.9 + math.sin(time + i) * 0.1),
            baseColor[2] * (0.9 + math.cos(time + i * 1.1) * 0.1),
            baseColor[3] * (0.9 + math.sin(time + i * 0.9) * 0.1),
            baseColor[4]
        }
        love.graphics.setColor(spotColor)
        love.graphics.circle("fill", spotX, spotY, spotSize)
    end
    
    -- Realistic fins with subtle movement
    local finWave = math.sin(time * 2) * 3
    love.graphics.setColor(baseColor[1] * 0.85, baseColor[2] * 0.85, baseColor[3] * 0.85, baseColor[4])
    local leftFinPoints = {
        x - 18, y + 12,
        x - 28, y + 20 + finWave,
        x - 25, y + 28,
        x - 10, y + 25
    }
    local rightFinPoints = {
        x + 18, y + 12,
        x + 28, y + 20 + finWave,
        x + 25, y + 28,
        x + 10, y + 25
    }
    love.graphics.polygon("fill", leftFinPoints)
    love.graphics.polygon("fill", rightFinPoints)
    
    -- Realistic eyes with depth and reflection
    -- Sclera
    love.graphics.setColor(0.95, 0.95, 1.0, 1)
    love.graphics.circle("fill", x - 12, y - 2, 7)
    love.graphics.circle("fill", x + 12, y - 2, 7)
    
    -- Iris
    love.graphics.setColor(0.7, 0.7, 0.9, 1)
    love.graphics.circle("fill", x - 12, y - 2, 5)
    love.graphics.circle("fill", x + 12, y - 2, 5)
    
    -- Pupil
    love.graphics.setColor(0, 0, 0.1, 1)
    love.graphics.circle("fill", x - 12, y - 2, 3)
    love.graphics.circle("fill", x + 12, y - 2, 3)
    
    -- Eye highlights - multiple for realism
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("fill", x - 14, y - 4, 1.5)
    love.graphics.circle("fill", x + 10, y - 4, 1.5)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("fill", x - 13, y - 1, 0.8)
    love.graphics.circle("fill", x + 11, y - 1, 0.8)
    
    -- Highly detailed arms with realistic movement and suckers
    for i = 1, 10 do
        local isLong = (i == 1 or i == 2 or i == 9 or i == 10)
        local angle = (i - 1) * 0.35 - 1.57
        local length = isLong and 70 or 40
        local baseX = x + math.cos(angle) * 18
        local baseY = y + 22 + thrust
        
        -- Create arm with multiple segments for fluid motion
        local segments = 12
        local armPoints = {baseX, baseY}
        local armWidth = isLong and 3 or 2
        
        -- Draw curved arm with gradient coloring
        for t = 1, segments do
            local segmentT = t / segments
            -- Complex wave motion based on time and position
            local wave = math.sin(time * 1.2 + i + segmentT * 3) * (1 - segmentT) * 8
            wave = wave + math.sin(time * 0.8 + i * 0.7 + segmentT * 2) * (1 - segmentT) * 4
            
            local tx = baseX + math.cos(angle) * length * segmentT + wave
            local ty = baseY + math.sin(angle) * length * segmentT
            table.insert(armPoints, tx)
            table.insert(armPoints, ty)
            
            -- Draw suckers with detailed appearance
            if segmentT > 0.1 and segmentT < 0.9 and t % 2 == 0 then
                local suckerSize = (isLong and 2.5 or 1.8) * (1 - segmentT * 0.7)
                
                -- Sucker base
                love.graphics.setColor(baseColor[1] * 0.85, baseColor[2] * 0.85, baseColor[3] * 0.85, baseColor[4])
                love.graphics.circle("fill", tx, ty, suckerSize)
                
                -- Sucker rim
                love.graphics.setColor(baseColor[1] * 0.75, baseColor[2] * 0.75, baseColor[3] * 0.75, baseColor[4])
                love.graphics.circle("line", tx, ty, suckerSize)
                
                -- Sucker center
                love.graphics.setColor(baseColor[1] * 0.65, baseColor[2] * 0.65, baseColor[3] * 0.65, baseColor[4])
                love.graphics.circle("fill", tx, ty, suckerSize * 0.5)
            end
        end
        
        -- Draw arm with thickness and gradient
        love.graphics.setColor(baseColor[1] * 1.1, baseColor[2] * 1.1, baseColor[3] * 1.1, baseColor[4])
        love.graphics.setLineWidth(armWidth * (1.2 - math.sin(time + i) * 0.1))
        love.graphics.line(armPoints)
    end
    
    -- Enhanced ink particles with fluid dynamics simulation
    if animState == 1 then
        love.graphics.setColor(0.1, 0.05, 0.02, 0.6)
        
        -- Create ink cloud with varying density
        for i = 1, 40 do
            local angle = math.random() * math.pi * 2
            local distance = math.random(5, 30)
            local size = math.random(1, 4)
            local alpha = 0.7 * (1 - distance / 35)
            
            -- Simulate ink diffusion with time
            local px = x + math.cos(angle) * distance + math.sin(time * 3 + i) * 5
            local py = y + 30 + math.sin(angle) * distance + math.cos(time * 3 + i) * 3
            
            love.graphics.setColor(0.1, 0.05, 0.02, alpha)
            love.graphics.circle("fill", px, py, size * (0.8 + math.sin(time + i) * 0.2))
        end
        
        -- Draw darker core of ink
        love.graphics.setColor(0.05, 0.02, 0.01, 0.8)
        for i = 1, 10 do
            local angle = math.random() * math.pi * 2
            local distance = math.random(2, 15)
            local px = x + math.cos(angle) * distance
            local py = y + 30 + math.sin(angle) * distance
            love.graphics.circle("fill", px, py, math.random(1.5, 3))
        end
    end
    
    love.graphics.setLineWidth(1)
end

function enemies.drawKraken (x, y, animState, color)
    local time = love.timer.getTime()
    local baseColor = color or {0.3, 0.2, 0.4, 1}
    
    -- Create organic head shape with irregular texture
    local headRadius = 35
    local headPoints = {}
    local segments = 36
    local thrash = math.sin(time * 0.6) * 4
    
    if animState == 1 then 
        thrash = math.sin(time * 5) * 7
    elseif animState == 2 then 
        thrash = math.sin(time * 8) * 6 
    end
    
    -- Create detailed head with organic irregularities
    for i = 0, segments do
        local angle = (math.pi * 2 * i) / segments
        -- Complex shape with multiple sine waves for organic look
        local radiusModifier = 1 + 
            math.sin(angle * 3) * 0.12 + 
            math.sin(angle * 7) * 0.05 + 
            math.sin(angle * 12 + time * 0.5) * 0.03
        
        local hx = x + math.cos(angle) * headRadius * radiusModifier
        local hy = y + math.sin(angle) * headRadius * 0.9 + thrash
        table.insert(headPoints, hx)
        table.insert(headPoints, hy)
    end
    
    -- Draw the main head with gradient coloring
    local gradientColors = {
        {baseColor[1] * 1.1, baseColor[2] * 1.1, baseColor[3] * 1.1, baseColor[4]},
        {baseColor[1] * 0.9, baseColor[2] * 0.9, baseColor[3] * 0.9, baseColor[4]},
        {baseColor[1], baseColor[2], baseColor[3], baseColor[4]}
    }
    
    love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], baseColor[4])
    love.graphics.polygon("fill", headPoints)
    
    -- Skin texture with varying spots and patterns
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2
        local radius = math.random(5, headRadius * 0.9)
        local spotX = x + math.cos(angle) * radius
        local spotY = y + math.sin(angle) * radius + thrash
        
        local spotColor = {
            baseColor[1] * (0.8 + math.random() * 0.4),
            baseColor[2] * (0.8 + math.random() * 0.4),
            baseColor[3] * (0.8 + math.random() * 0.4),
            0.6
        }
        
        love.graphics.setColor(spotColor)
        love.graphics.circle("fill", spotX, spotY, math.random(1, 3))
    end
    
    -- Beak with detail
    love.graphics.setColor(0.2, 0.1, 0.05, 1)
    local beakSize = 8 + math.sin(time) * 0.5
    -- Upper beak
    love.graphics.polygon("fill", 
        x - beakSize, y + 25, 
        x + beakSize, y + 25, 
        x, y + 35 + math.sin(time * 2) * 2
    )
    -- Lower beak
    love.graphics.setColor(0.15, 0.08, 0.04, 1)
    love.graphics.polygon("fill", 
        x - beakSize * 0.8, y + 28, 
        x + beakSize * 0.8, y + 28, 
        x, y + 33 + math.sin(time * 2) * 2
    )
    
    -- Realistic glowing eyes with depth and reflections
    -- Eye socket shadow
    love.graphics.setColor(baseColor[1] * 0.6, baseColor[2] * 0.6, baseColor[3] * 0.6, 1)
    love.graphics.circle("fill", x - 14, y - 8, 10)
    love.graphics.circle("fill", x + 14, y - 8, 10)
    
    -- Main eye
    love.graphics.setColor(0.9, 0.4, 0.2, 1)
    love.graphics.circle("fill", x - 14, y - 8, 8)
    love.graphics.circle("fill", x + 14, y - 8, 8)
    
    -- Iris with glow effect
    love.graphics.setColor(1, 0.6, 0.3, 0.9)
    love.graphics.circle("fill", x - 14, y - 8, 5)
    love.graphics.circle("fill", x + 14, y - 8, 5)
    
    -- Pupil that dilates based on animation state
    local pupilSize = 3
    if animState == 1 then pupilSize = 2
    elseif animState == 2 then pupilSize = 4 end
    
    love.graphics.setColor(0.1, 0.05, 0, 1)
    love.graphics.circle("fill", x - 14, y - 8, pupilSize)
    love.graphics.circle("fill", x + 14, y - 8, pupilSize)
    
    -- Eye highlights for depth
    love.graphics.setColor(1, 0.8, 0.6, 0.8)
    love.graphics.circle("fill", x - 16, y - 10, 2)
    love.graphics.circle("fill", x + 12, y - 10, 2)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("fill", x - 15, y - 7, 1)
    love.graphics.circle("fill", x + 13, y - 7, 1)
    
    -- Highly detailed tentacles with realistic movement and hooks
    for i = 1, 16 do
        local isShorter = (i > 8 and i <= 12)
        local isLonger = (i <= 4)
        local angle = (i - 1) * 0.39 - 1.57
        
        local length = isLonger and 85 or (isShorter and 55 or 70)
        local baseX = x + math.cos(angle) * headRadius * 0.9
        local baseY = y + headRadius * 0.85 + thrash
        
        -- Create tentacle with multiple segments for fluid motion
        local segments = 20
        local tentaclePoints = {baseX, baseY}
        local tentacleWidth = isLonger and 5 or (isShorter and 3 or 4)
        
        -- Unique movement pattern for each tentacle
        local uniquePhase = i * 0.3
        
        for t = 1, segments do
            local segmentT = t / segments
            -- Complex wave pattern for realistic movement
            local wave = math.sin(time * 1.2 + uniquePhase + segmentT * 3) * (1 - segmentT) * 15
            wave = wave + math.cos(time * 0.8 + uniquePhase * 0.7 + segmentT * 2) * (1 - segmentT) * 10
            
            -- Add more dramatic movement during animation states
            if animState > 0 then
                wave = wave * (1 + animState * 0.3)
            end
            
            local tx = baseX + math.cos(angle) * length * segmentT + wave
            local ty = baseY + math.sin(angle) * length * segmentT
            table.insert(tentaclePoints, tx)
            table.insert(tentaclePoints, ty)
            
            -- Add hooks and suckers with detailed appearance
            if segmentT > 0.2 and segmentT < 0.9 and t % 3 == 0 then
                -- Calculate perpendicular angle for hook placement
                local nextPointIndex = math.min((t + 1), segments)
                local nextT = nextPointIndex / segments
                local nextWave = math.sin(time * 1.2 + uniquePhase + nextT * 3) * (1 - nextT) * 15
                nextWave = nextWave + math.cos(time * 0.8 + uniquePhase * 0.7 + nextT * 2) * (1 - nextT) * 10
                local nextX = baseX + math.cos(angle) * length * nextT + nextWave
                local nextY = baseY + math.sin(angle) * length * nextT
                
                local dx = nextX - tx
                local dy = nextY - ty
                local perpAngle = math.atan2(dy, dx) + math.pi/2
                
                local hookSize = (isLonger and 4 or 3) * (1 - segmentT * 0.5)
                local hookBaseX = tx + math.cos(perpAngle) * tentacleWidth * 0.5
                local hookBaseY = ty + math.sin(perpAngle) * tentacleWidth * 0.5
                
                -- Sharp hook with detailed shape
                love.graphics.setColor(0.5, 0.3, 0.6, 1)
                love.graphics.polygon("fill", 
                    hookBaseX, hookBaseY,
                    hookBaseX + math.cos(perpAngle) * hookSize, hookBaseY + math.sin(perpAngle) * hookSize,
                    hookBaseX + math.cos(perpAngle + 0.7) * hookSize * 1.2, hookBaseY + math.sin(perpAngle + 0.7) * hookSize * 1.2
                )
                
                -- Hook highlight
                love.graphics.setColor(0.7, 0.5, 0.8, 0.7)
                love.graphics.line(
                    hookBaseX, hookBaseY,
                    hookBaseX + math.cos(perpAngle + 0.3) * hookSize * 0.8, hookBaseY + math.sin(perpAngle + 0.3) * hookSize * 0.8
                )
            end
        end
        
        -- Draw tentacle with thickness that tapers
        for t = 1, segments - 1 do
            local thickness = tentacleWidth * (1 - (t / segments) * 0.7)
            local x1, y1 = tentaclePoints[t*2-1], tentaclePoints[t*2]
            local x2, y2 = tentaclePoints[t*2+1], tentaclePoints[t*2+2]
            
            love.graphics.setColor(baseColor[1] * (1.1 - t/segments * 0.3), 
                                  baseColor[2] * (1.1 - t/segments * 0.3), 
                                  baseColor[3] * (1.1 - t/segments * 0.3), 
                                  baseColor[4])
            love.graphics.setLineWidth(thickness)
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    
    -- Draw water displacement effects when moving aggressively
    if animState > 0 then
        local intensity = animState * 0.3
        love.graphics.setColor(1, 1, 1, 0.2 * intensity)
        
        for i = 1, 12 do
            local angle = i * math.pi / 6
            local radius = headRadius * (1.2 + math.sin(time * 5 + i) * 0.2) * intensity
            local px = x + math.cos(angle) * radius
            local py = y + math.sin(angle) * radius + thrash
            love.graphics.circle("line", px, py, 5 + math.sin(time * 3 + i) * 3)
        end
    end
    
    love.graphics.setLineWidth(1)
end

function enemies.drawLeviathan (x, y, animState, color)
    local time = love.timer.getTime()
    local baseColor = color or {0.1, 0.4, 0.3, 1}
    
    -- Animation and behavior parameters
    local sway = math.sin(time * 0.6) * 1.5
    if animState == 1 then 
        sway = math.sin(time * 4) * 2.5  -- Agitated movement
    elseif animState == 2 then 
        sway = math.sin(time * 6) * 2    -- Attack movement
    end
    
    -- Shadow for depth perception
    love.graphics.setColor(0, 0, 0, 0.3)
    local shadowPoints = {}
    for i = -25, 25, 1 do
        local bx = x + i * 2.5 + 8
        local by = y + math.sin(i * 0.25 + time) * 12 * (1 - math.abs(i) / 25) + sway * 6 + 15
        table.insert(shadowPoints, bx)
        table.insert(shadowPoints, by - 10 * (1 - math.abs(i) / 25))
        table.insert(shadowPoints, bx)
        table.insert(shadowPoints, by + 10 * (1 - math.abs(i) / 25))
    end
    love.graphics.polygon("fill", shadowPoints)
    
    -- Underwater glow effect
    local glowRadius = 120 + math.sin(time * 0.8) * 15
    love.graphics.setColor(baseColor[1] * 0.3, baseColor[2] * 0.4, baseColor[3] * 0.5, 0.1)
    love.graphics.circle("fill", x, y, glowRadius)
    
    -- Body: Detailed serpentine form with undulation
    local bodySegments = 25
    local bodyWidth = 24
    local bodyPoints = {}
    
    -- Create main body shape with realistic tapering
    for i = -bodySegments, bodySegments, 1 do
        local segment = i / bodySegments
        local width = bodyWidth * (1 - 0.7 * math.abs(segment)^1.5)
        local offset = segment * 2.5 * bodySegments
        
        -- Wave patterns combine for organic movement
        local primaryWave = math.sin(segment * 2 + time * 0.8) * 12
        local secondaryWave = math.sin(segment * 4 + time * 1.2) * 4 * (1 - math.abs(segment))
        local tertiaryWave = math.cos(segment * 8 + time * 0.4) * 2 * (1 - math.abs(segment))
        
        local bx = x + offset
        local by = y + primaryWave + secondaryWave + tertiaryWave + sway * (1 - math.abs(segment)) * 6
        
        -- Upper body curve
        table.insert(bodyPoints, bx)
        table.insert(bodyPoints, by - width)
    end
    
    -- Lower body curve (in reverse to complete the polygon)
    for i = bodySegments, -bodySegments, -1 do
        local segment = i / bodySegments
        local width = bodyWidth * (1 - 0.7 * math.abs(segment)^1.5)
        local offset = segment * 2.5 * bodySegments
        
        local primaryWave = math.sin(segment * 2 + time * 0.8) * 12
        local secondaryWave = math.sin(segment * 4 + time * 1.2) * 4 * (1 - math.abs(segment))
        local tertiaryWave = math.cos(segment * 8 + time * 0.4) * 2 * (1 - math.abs(segment))
        
        local bx = x + offset
        local by = y + primaryWave + secondaryWave + tertiaryWave + sway * (1 - math.abs(segment)) * 6
        
        table.insert(bodyPoints, bx)
        table.insert(bodyPoints, by + width)
    end
    
    -- Main body gradient
    local bodyGradient = {
        baseColor[1], baseColor[2], baseColor[3], baseColor[4],
        baseColor[1] * 0.7, baseColor[2] * 0.7, baseColor[3] * 0.7, baseColor[4]
    }
    love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], baseColor[4])
    love.graphics.polygon("fill", bodyPoints)
    
    -- Scale texture (multiple layers for depth)
    for layer = 1, 3 do
        local layerOffset = (layer - 2) * 2
        local layerAlpha = 0.7 / layer
        local scaleSpacing = 5 - layer
        
        for i = -bodySegments + 2, bodySegments - 2, scaleSpacing do
            local segment = i / bodySegments
            local scaleSize = (1 - 0.6 * math.abs(segment)) * (5 - layer)
            local offset = segment * 2.5 * bodySegments
            
            local primaryWave = math.sin(segment * 2 + time * 0.8) * 12
            local secondaryWave = math.sin(segment * 4 + time * 1.2) * 4 * (1 - math.abs(segment))
            
            local sx = x + offset + layerOffset
            local sy = y + primaryWave + secondaryWave + sway * (1 - math.abs(segment)) * 6
            
            -- Alternating scale patterns
            if i % 2 == 0 then
                love.graphics.setColor(
                    baseColor[1] * (0.8 + 0.2 * math.sin(i + time)),
                    baseColor[2] * (0.8 + 0.2 * math.sin(i + time + 1)),
                    baseColor[3] * (0.8 + 0.2 * math.sin(i + time + 2)),
                    layerAlpha
                )
                love.graphics.polygon("fill",
                    sx, sy - scaleSize * 1.5,
                    sx - scaleSize, sy - scaleSize * 0.5,
                    sx, sy + scaleSize * 0.5,
                    sx + scaleSize, sy - scaleSize * 0.5
                )
            else
                love.graphics.setColor(
                    baseColor[1] * (0.7 + 0.2 * math.sin(i + time)),
                    baseColor[2] * (0.7 + 0.2 * math.sin(i + time + 1)),
                    baseColor[3] * (0.7 + 0.2 * math.sin(i + time + 2)),
                    layerAlpha
                )
                love.graphics.polygon("fill",
                    sx, sy + scaleSize * 1.5,
                    sx - scaleSize, sy + scaleSize * 0.5,
                    sx, sy - scaleSize * 0.5,
                    sx + scaleSize, sy + scaleSize * 0.5
                )
            end
        end
    end
    
    -- Bioluminescent spots along the body
    if math.random() < 0.02 then -- Occasional flashing
        for i = -bodySegments + 5, bodySegments - 5, 8 do
            local segment = i / bodySegments
            local glowX = x + segment * 2.5 * bodySegments
            local glowY = y + math.sin(segment * 2 + time * 0.8) * 12 + sway * (1 - math.abs(segment)) * 6
            
            -- Outer glow
            local glowIntensity = 0.5 + 0.5 * math.sin(time * 3 + i)
            love.graphics.setColor(
                baseColor[1] * 2, 
                baseColor[2] * 2, 
                baseColor[3] * 2, 
                0.3 * glowIntensity
            )
            love.graphics.circle("fill", glowX, glowY - 12, 4 + math.sin(time * 5 + i) * 2)
            
            -- Inner bright spot
            love.graphics.setColor(1, 1, 0.9, 0.8 * glowIntensity)
            love.graphics.circle("fill", glowX, glowY - 12, 2)
        end
    end
    
    -- Dynamic fins: dorsal, ventral, and side fins
    for i = -18, 18, 6 do
        local segment = i / bodySegments
        local finBase = x + segment * 2.5 * bodySegments
        local finY = y + math.sin(segment * 2 + time * 0.8) * 12 + sway * (1 - math.abs(segment)) * 6
        
        -- Fin size and shape varies along body
        local finHeight = 14 * (1 - 0.7 * math.abs(segment))
        local finWidth = 8 * (1 - 0.5 * math.abs(segment))
        
        -- Fin animation
        local finWave = math.sin(time * 2 + segment * 4) * 3
        
        -- Dorsal fin
        love.graphics.setColor(baseColor[1] * 0.8, baseColor[2] * 0.8, baseColor[3] * 0.8, 0.9)
        love.graphics.polygon("fill",
            finBase, finY - bodyWidth * (1 - 0.7 * math.abs(segment)), -- Base
            finBase - finWidth, finY - bodyWidth * (1 - 0.7 * math.abs(segment)) - finHeight + finWave, -- Back
            finBase + finWidth * 0.7, finY - bodyWidth * (1 - 0.7 * math.abs(segment)) - finHeight * 1.2 - finWave -- Front
        )
        
        -- Ventral fin
        love.graphics.polygon("fill",
            finBase, finY + bodyWidth * (1 - 0.7 * math.abs(segment)), -- Base
            finBase - finWidth * 0.8, finY + bodyWidth * (1 - 0.7 * math.abs(segment)) + finHeight * 0.7 - finWave, -- Back
            finBase + finWidth * 0.5, finY + bodyWidth * (1 - 0.7 * math.abs(segment)) + finHeight - finWave -- Front
        )
        
        -- Side fins (only on middle sections)
        if math.abs(segment) < 0.6 and math.abs(segment) > 0.2 then
            local sideFinSize = 10 * (1 - math.abs((math.abs(segment) - 0.4) / 0.2))
            local sideFinY = finY + math.cos(segment * 10) * bodyWidth * 0.5
            love.graphics.polygon("fill",
                finBase, sideFinY, -- Base
                finBase + sideFinSize, sideFinY - sideFinSize * 0.7 + finWave * 0.5, -- Top
                finBase + sideFinSize * 1.5, sideFinY, -- Tip
                finBase + sideFinSize, sideFinY + sideFinSize * 0.7 - finWave * 0.5 -- Bottom
            )
        end
    end
    
    -- Head structure
    local headX = x - bodySegments * 2.5
    local headY = y + math.sin(-1 + time * 0.8) * 12 + sway * 0.8 * 6
    local headWidth = bodyWidth * 0.9
    local headLength = bodyWidth * 2
    
    -- Basic head shape
    love.graphics.setColor(baseColor[1] * 0.7, baseColor[2] * 0.7, baseColor[3] * 0.7, baseColor[4])
    love.graphics.polygon("fill",
        headX, headY, -- Back center
        headX - headLength, headY - headWidth * 0.6, -- Top front
        headX - headLength * 1.2, headY, -- Front tip
        headX - headLength, headY + headWidth * 0.6 -- Bottom front
    )
    
    -- Eye (glowing and animated)
    local eyePulse = 0.7 + 0.3 * math.sin(time * 1.5)
    local eyeX = headX - headLength * 0.6
    local eyeY = headY - headWidth * 0.3
    
    -- Eye glow
    love.graphics.setColor(baseColor[1] * 2, baseColor[2] * 2, baseColor[3] * 2, 0.3 * eyePulse)
    love.graphics.circle("fill", eyeX, eyeY, 6)
    
    -- Eye outer
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.circle("fill", eyeX, eyeY, 4)
    
    -- Eye inner (pupil)
    love.graphics.setColor(0.9, 0.8, 0.1, eyePulse)
    love.graphics.circle("fill", eyeX, eyeY, 2)
    
    -- Gleam
    love.graphics.setColor(1, 1, 1, 0.8 * eyePulse)
    love.graphics.circle("fill", eyeX - 1, eyeY - 1, 1)
    
    -- Jaw structure and teeth
    local jawOpenFactor = 0.2
    if animState == 1 then jawOpenFactor = 0.4 + 0.2 * math.sin(time * 8)
    elseif animState == 2 then jawOpenFactor = 0.8 + 0.2 * math.sin(time * 12) end
    
    -- Upper jaw
    love.graphics.setColor(baseColor[1] * 0.65, baseColor[2] * 0.65, baseColor[3] * 0.65, baseColor[4])
    love.graphics.polygon("fill",
        headX - headLength * 0.8, headY - headWidth * 0.3, -- Back top
        headX - headLength * 1.2, headY - headWidth * 0.1, -- Front top
        headX - headLength * 1.2, headY - jawOpenFactor * headWidth * 0.3, -- Front bottom
        headX - headLength * 0.8, headY -- Back bottom
    )
    
    -- Lower jaw
    love.graphics.polygon("fill",
        headX - headLength * 0.8, headY, -- Back top
        headX - headLength * 1.2, headY + jawOpenFactor * headWidth * 0.3, -- Front top
        headX - headLength * 1.1, headY + headWidth * 0.4, -- Front bottom
        headX - headLength * 0.7, headY + headWidth * 0.2 -- Back bottom
    )
    
    -- Upper teeth
    love.graphics.setColor(0.95, 0.95, 0.9, 0.9)
    for i = 0, 6 do
        local toothX = headX - headLength * (0.85 + i * 0.06)
        local toothY = headY - jawOpenFactor * headWidth * 0.15
        local toothSize = 3 * (1 - 0.5 * math.abs(i - 3) / 3)
        
        love.graphics.polygon("fill",
            toothX, toothY,
            toothX - toothSize * 0.3, toothY + toothSize,
            toothX + toothSize * 0.3, toothY + toothSize
        )
    end
    
    -- Lower teeth
    for i = 0, 5 do
        local toothX = headX - headLength * (0.88 + i * 0.06)
        local toothY = headY + jawOpenFactor * headWidth * 0.15
        local toothSize = 2.8 * (1 - 0.5 * math.abs(i - 2.5) / 2.5)
        
        love.graphics.polygon("fill",
            toothX, toothY,
            toothX - toothSize * 0.3, toothY - toothSize,
            toothX + toothSize * 0.3, toothY - toothSize
        )
    end
    
    -- Water displacement effects (bubbles and ripples when moving fast)
    if animState == 1 or animState == 2 then
        love.graphics.setColor(1, 1, 1, 0.4)
        for i = 1, 10 do
            local bubbleX = x - math.random(0, 120)
            local bubbleY = y + math.random(-30, 30)
            local bubbleSize = math.random(1, 3)
            love.graphics.circle("fill", bubbleX, bubbleY, bubbleSize)
        end
        
        -- Wake/turbulence behind the creature
        love.graphics.setColor(1, 1, 1, 0.2)
        for i = 1, 5 do
            local wakeX = x + 30 + i * 10
            local wakeY = y + math.sin(time * 4 + i) * 5
            local wakeSize = 15 - i * 2
            love.graphics.circle("fill", wakeX, wakeY, wakeSize)
        end
    end
end

-- Enemy data
enemies.list = {
    { name = "Jellyfish", baseHealth = 20, baseAttack = 10, baseDefense = 2, currency = 10, baseColor = {0.3, 0.3, 0.9, 1}, type = 1 },
    { name = "Angler", baseHealth = 35, baseAttack = 13, baseDefense = 3, currency = 15, baseColor = {0.8, 0.5, 0.2, 1}, type = 1 },
    { name = "Squid", baseHealth = 50, baseAttack = 15, baseDefense = 5, currency = 25, baseColor = {0.6, 0.2, 0.6, 1}, type = 2 },
    { name = "Kraken", baseHealth = 100, baseAttack = 20, baseDefense = 10, currency = 50, baseColor = {0.7, 0.1, 0.2, 1}, type = 3 },
    { name = "Leviathan", baseHealth = 200, baseAttack = 22, baseDefense = 15, currency = 100, baseColor = {0.2, 0.1, 0.8, 1}, type = 4 }
}

-- Define abilities per enemy
enemies.abilities = {
    Jellyfish = { name = "Sting", chance = 0.3, effect = "poison", damage = 5, duration = 2 },
    Angler = { name = "Lure Strike", chance = 0.5, effect = "stun", damage = 8, duration = 1 },
    Squid = { name = "Ink Cloud", chance = 0.4, effect = "slow", damage = 0, duration = 2 },
    Kraken = { name = "Tentacle Slam", chance = 0.35, effect = "bleed", damage = 10, duration = 3 },
    Leviathan = { name = "Crushing Bite", chance = 0.25, effect = "bleed", damage = 15, duration = 2 }
}

-- Function to retrieve ability for an enemy
function enemies.getAbility(name)
    return enemies.abilities[name] or { name = "Basic Attack", chance = 0, effect = nil, damage = 0, duration = 0 }
end

-- Function to get a random enemy based on depth level
function enemies.getRandomEnemy(depthLevel)
    local enemyOptions = {}
    local maxType = math.min(3, math.max(1, math.floor(depthLevel / 5)))
    for _, enemy in ipairs(enemies.list) do
        if enemy.type <= maxType then
            table.insert(enemyOptions, enemy)
        end
    end
    return enemyOptions[love.math.random(1, #enemyOptions)]
end

return enemies