function toggleGtaSounds(enabled)
setWorldSoundEnabled(40,0,not enabled, true) -- infernus/comet accelerate
setWorldSoundEnabled(40,2,not enabled, true) -- infernus/comet let off gas

--setWorldSoundEnabled(19,24,not enabled, true) -- tarmac skid
--setWorldSoundEnabled(19,25,not enabled, true) -- more wind?
--setWorldSoundEnabled(19,21,not enabled, true) -- wind
--setWorldSoundEnabled(19,20,not enabled, true) -- ?
--setWorldSoundEnabled(19,19,not enabled, true) -- reverse

setWorldSoundEnabled(7,0,not enabled, true) -- launch stratum
setWorldSoundEnabled(7,1,not enabled, true) -- decelerate stratum

setWorldSoundEnabled(8,0,not enabled, true) -- launch infernus
setWorldSoundEnabled(8,1,not enabled, true) -- decelerate infernus

setWorldSoundEnabled(9,0,not enabled, true) -- bandito
setWorldSoundEnabled(9,1,not enabled, true) -- 

setWorldSoundEnabled(10,0,not enabled, true) -- bullet
setWorldSoundEnabled(10,1,not enabled, true) -- bullet

setWorldSoundEnabled(11,0,not enabled, true) -- picador
setWorldSoundEnabled(11,1,not enabled, true) -- picador

setWorldSoundEnabled(12,0,not enabled, true) -- launch phoenix
setWorldSoundEnabled(12,1,not enabled, true) -- decelerate phoenix

setWorldSoundEnabled(13,0,not enabled, true) -- launch comet
setWorldSoundEnabled(13,1,not enabled, true) -- decelerate comet

setWorldSoundEnabled(14,0,not enabled, true) -- truck (linerunner)
setWorldSoundEnabled(14,1,not enabled, true) -- truck / kart

setWorldSoundEnabled(15,0,not enabled, true) -- monster
setWorldSoundEnabled(15,1,not enabled, true) -- 

setWorldSoundEnabled(16,0,not enabled, true) -- pcj-600
setWorldSoundEnabled(16,1,not enabled, true) --  monster

end

