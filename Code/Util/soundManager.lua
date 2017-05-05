local soundManager = {}
    -- will hold the currently playing sources
    local sources = {}
    local mute = false
 
    -- check for sources that finished playing and remove them
    -- add to love.update
    function soundManager.update()
        local remove = {}
        for _,s in pairs(sources) do

            if s:isStopped() then
                remove[#remove + 1] = s
            end
        end
 
        for i,s in ipairs(remove) do
            sources[s] = nil
        end
    end
 
    -- overwrite love.audio.play to create and register source if needed
    local play = love.audio.play
    function soundManager.play(what, how, loop, volume, pitch)
        local src = what
        if type(what) ~= "userdata" or not what:typeOf("Source") then
            src = love.audio.newSource(what, how)
            src:setVolume(volume or 1)
            src:setPitch(pitch or 1)
            src:setLooping(loop or false)
        end
        if not mute then
            play(src)
        end
        
        sources[src] = src
        return src
    end
 
    -- stops a source
    local stop = love.audio.stop
    function soundManager.stop(src)
        if not src then return end
        stop(src)
        sources[src] = nil
    end

    function soundManager.setMute(bool)
        mute = bool
    end

return soundManager