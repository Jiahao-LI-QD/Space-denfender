note
	description: "Summary description for {ENEMY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENEMY

inherit
	OBJECT
		rename
			make as make_empty
		end

feature --attribute
	max_health: INTEGER
	h_r: INTEGER
	armour: INTEGER
	vision: INTEGER
	seen_by_starfighter: BOOLEAN
	can_see_starfighter: BOOLEAN

	model: GAME
	ready:BOOLEAN
	pos: PAIR[INTEGER, INTEGER]
	health: INTEGER
	orb: ORBMENT
	m: STRING
feature --command
	make(i, r, c: INTEGER)
		local
			ga: GAME_ACCESS
		do
			create m.make_empty
			model:= ga.m
			id := i
			create pos.make (r, c)
			active := true
			ready:= true
			occupied := true
			update_vision
		end

	set_ready
		do
			ready := true
		end

	not_ready
		do
			ready := false
		end

	collide(p: PROJECTILE)
		do
			p.inactive
			if p.type = 0 then
				health := health + p.damage
				if health > max_health then
					health:= max_health
				end
			else
				if p.damage > armour then
					health := health - p.damage + armour
				end
			end
			if health <= 0 then
				enemy_over
				model.board.put (create {OBJECT}.make, pos.first, pos.second)
			end
		end

	in_board: BOOLEAN
			local
				r, c:INTEGER
			do
				r:= pos.first
				c:= pos.second
				if r < 1 or r > model.max_r or c < 1 or c > model.max_c then
					Result := false
				else
					Result := true
				end
			ensure
				Result = (0 < pos.first and pos.first <= model.max_r and 0 < pos.second and pos.second <= model.max_c)
			end

	update_vision
		do
			can_see_starfighter := (pos.first - model.star.pos.first).abs + (pos.second - model.star.pos.second).abs <= vision
			seen_by_starfighter := model.star.in_vision (pos.first, pos.second)
		end

	action
		require
			ready_to_act: ready_to_act
		deferred
		ensure
			case_current_inactive: not active implies (not in_board or health = 0)
			case_star_destroyed: model.star.destroyed implies (model.star.health = 0)
		end

	preemptive_action
		require
			ready_to_pre_act: ready_to_act
		deferred
		ensure
			case_current_inactive: not active implies (not in_board or health = 0)
			case_star_destroyed: model.star.destroyed implies (model.star.health = 0)
		end

	enemy_over
		do
			inactive
			health := 0
			model.star.focus.add (orb)
		end

	ready_to_act: BOOLEAN
		do
			Result := model.in_game and not model.star.destroyed and active and ready
		end

	regeneration
		require
			ready_to_gen: ready_to_act
		do
			heal(h_r)
		ensure
			not_exceed_max: health <= max_health
			full_regen: (health = old health + h_r) implies (old health <= max_health - h_r)
			regen_to_max: health = max_health implies (old health >= max_health - h_r)
		end

	heal(h:INTEGER)
		do
			if health < max_health then
				health := health + h
				if health > max_health then
					health := max_health
				end
			end
		end

	T_F(b:BOOLEAN):STRING
	    do
	    	if b then
	    		create Result.make_from_string("T")
	    	else
	    		create Result.make_from_string("F")
	    	end
		end

	move_to(r, c: INTEGER)
		local
			o_pos: like pos
			i:INTEGER
		do
			create o_pos.make_from_tuple (pos)
			model.board.put (create {OBJECT}.make, pos.first, pos.second)
			-----------3 cases
----------------------------------------------------------------------
			from
				i := o_pos.second
			until
				i = c  or not active or (i - 1 >0 and then model.board[pos.first,i - 1].id > 0)
			loop
				i := i - 1
				pos.make (pos.first, i)
				if not in_board then
					inactive
				end
				if active and then attached model.board[pos.first, pos.second] as o then
					if o.occupied then
						if o.id < 0 and then attached {PROJECTILE} o as p then
							collide(p)
							model.board.put (create {OBJECT}.make, pos.first,pos.second)
							if p.type = 0 then
--The <enemy name> collides with enemy projectile(id:<id>) at location [X,Y], healing <projectile damage> damage
								m.append ("      The " + full_name + " collides with enemy projectile(id:" + p.id.out +") at location ")
								m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], healing "+p.damage.out +" damage.%N")
							else
--The <enemy name> collides with friendly projectile(id:<id>) at location [X,Y], taking <projectile damage - enemy armour> damage.
								m.append ("      The " + full_name + " collides with friendly projectile(id:" + p.id.out +") at location ")
								m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], taking ")
								if p.damage > armour then
									m.append ((p.damage - armour).out +" damage.%N")
								else
									m.append ("0 damage.%N")
								end
							end
						else
							inactive
							m.append ("      The " + full_name + " collides with Starfighter(id:0) at location ")
							m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], trading "+ health.out +" damage.%N")
							model.star.collide_e (current)

							--"The <enemy name> collides with Starfighter(id:0) at location [X,Y], trading <enemy current health> damage."
						end
							if not active then
								m.append ("      The " + full_name + " at location ["+ model.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")

							end
							if model.star.destroyed then
								m.append ("      The Starfighter at location [" + model.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
							end
					end
				end
			end
			if active then
				model.board.put (current, pos.first, pos.second)
			end
--    A Grunt(id:1) moves: [A,30] -> [A,28]

			if o_pos.second = pos.second then
			--	stays at:
				model.update_enemies_act ("    A " + full_name + "(id:" + id.out + ") stays at: ")
				model.update_enemies_act ("[" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "]%N")

			else

				model.update_enemies_act ("    A " + full_name + "(id:" + id.out + ") moves: ")
				model.update_enemies_act ("[" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "] -> ")
				if in_board then
					model.update_enemies_act ("[" + model.rows[pos.first].out + "," + pos.second.out+ "]%N")
				else
					model.update_enemies_act ("out of board%N")
				end
			end
		end

	full_name: STRING
		do
			if content = 'G' then
				create Result.make_from_string("Grunt")
			elseif content = 'F' then
				create Result.make_from_string("Fighter")
			elseif content = 'C' then
				create Result.make_from_string("Carrier")
			elseif content = 'I' then
				create Result.make_from_string("Interceptor")
			else
				create Result.make_from_string("Pylon")
			end
		end

	damage(d:INTEGER)
		do
			health := health - d
		end

	display:STRING
		do
			create Result.make_empty
			Result.append ("    [" + id.out + "," + content.out + "]->")
			Result.append ("health:" + health.out + "/" + max_health.out + ", ")
			Result.append ("Regen:" +h_r.out + ", ")
			Result.append ("Armour:" + armour.out + ", ")
			Result.append ("Vision:" + vision.out + ", ")
			Result.append ("seen_by_Starfighter:" + T_F(seen_by_starfighter) + ", ")
			Result.append ("can_see_Starfighter:" + T_F(can_see_starfighter) + ", ")
			Result.append ("location:[" + model.rows[pos.first].out + "," + pos.second.out+ "]%N")
		end
end
