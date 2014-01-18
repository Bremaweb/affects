function applyAffect(name,affectid)
	minetest.log("action","Applying affect "..affectid.." on "..name)
	local player = minetest.get_player_by_name(name)	
	
	local oStage = affects._affectedPlayers[name][affectid].stage
	-- see if they need advanced into the next stage	
	if ( affects._affectedPlayers[name][affectid].nextStage < whoison.getTimeOnline(name) ) then		
		affects._affectedPlayers[name][affectid].stage = affects._affectedPlayers[name][affectid].stage + 1
		affects._affectedPlayers[name][affectid].ran = false
		if ( #affects._affects[affectid].stages < affects._affectedPlayers[name][affectid].stage ) then
			minetest.log("action","Affect "..affectid.." has worn off of "..name)
			affects.removeAffect(name,affectid)
			return
		end
	end
	
	local iStage = affects._affectedPlayers[name][affectid].stage
	local stage = affects._affects[affectid].stages[iStage]
	local oPhysics = stage.physics

	if ( oPhysics ~= nil ) then		
		player:set_physics_override(oPhysics)
	end	
	
	if ( stage.damage ~= nil ) then
		if ( randomChance(stage.damage.chance) ) then			
			player:set_hp( player:get_hp() - stage.damage.amount )
		end
	end
	
	if ( stage.emote ~= nil ) then
		if ( randomChance(stage.emote.chance) ) then			
			minetest.chat_send_all(name.." "..stage.emote.action)
		end
	end
	
	if ( stage.place ~= nil ) then
		if ( randomChance(stage.place.chance) ) then
			minetest.place_node(player:getpos(),{name=stage.place.node, param1=0, param2=0})	
		end
	end
	
	if ( stage.custom ~= nil ) then
		if ( stage.custom.runonce == true and affects._affectedPlayers[name][affectid].ran == true ) then			
			return
		end
		if ( randomChance(stage.custom.chance) ) then
			affects._affectedPlayers[name][affectid].ran = true			
			stage.custom.func(name,player,affectid)
		end
	end	
end

function randomChance (percent) 
	math.randomseed( os.time() )
	return percent >= math.random(1, 100)                                          
end
