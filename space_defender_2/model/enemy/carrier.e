note
	description: "Summary description for {CARRIER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CARRIER
inherit
	ENEMY
		redefine
			make
		end

create
	make

feature
	make(i, r, c:INTEGER)
		do
			content := 'C'
			max_health := 200
			h_r := 10
			armour := 15
			vision := 15
			health := max_health
			Precursor(i, r, c)
			create {DIAMOND} orb.make
		end
	action
		do
			m.wipe_out
			regeneration
			if can_see_starfighter then
--      A enemy projectile(id:-1) spawns at location [A,27].
				move_to (pos.first, pos.second - 1)
				if active then
					if not on_board (pos.first, pos.second - 1) or else not (model.board[pos.first, pos.second -1].id > 0) then
						generate (pos.first, pos.second - 1)
					end
				end
			else
				move_to (pos.first, pos.second - 2)
			end
				model.update_enemies_act (m)
		end
	preemptive_action
		do
			m.wipe_out
			if model.action_type = 1 then

				regeneration
				move_to (pos.first, pos.second - 2)
				if active then
					if not on_board (pos.first - 1, pos.second) or else not (model.board[pos.first - 1, pos.second].id > 0) then
						generate (pos.first - 1, pos.second)
					end

					if not on_board (pos.first + 1, pos.second) or else not (model.board[pos.first + 1, pos.second].id > 0) then
						generate (pos.first + 1, pos.second)
					end

					ready := false
				end
			elseif model.action_type = 4 then
				h_r := h_r + 10
				model.update_enemies_act ("    A "+ full_name + "(id:" + id.out + ") gains 10 regen.%N")
			end
			model.update_enemies_act (m)
		end

	generate(r,c:INTEGER)
		local
			e: ENEMY
		do
				create {INTERCEPTOR} e.make (model.enemies.count + 1, r, c)
				e.not_ready
				model.enemies.extend (e)
				m.append ("      A " + e.full_name)
				m.append("(id:" + e.id.out + ") spawns at location ")
					if e.in_board then
						m.append ("[" + model.rows[e.pos.first].out + "," + e.pos.second.out+ "].%N")
					else
						m.append ("out of board.%N")
					end

					if not e.in_board then
						e.inactive
					else
						if model.board[r,c].occupied then
							if  model.board[r,c].id < 0 then
								check attached {PROJECTILE} model.board[r,c] as p then
									e.collide (p)
									if p.type = 0 then
--The <enemy name> collides with enemy projectile(id:<id>) at location [X,Y], healing <projectile damage> damage
										m.append ("      The " + e.full_name + " collides with enemy projectile(id:" + p.id.out +") at location ")
										m.append ("[" + model.rows[e.pos.first].out + "," + e.pos.second.out+ "], healing "+p.damage.out +" damage.%N")
									else
--The <enemy name> collides with friendly projectile(id:<id>) at location [X,Y], taking <projectile damage - enemy armour> damage.
										m.append ("      The " + e.full_name + " collides with friendly projectile(id:" + p.id.out +") at location ")
										m.append ("[" + model.rows[e.pos.first].out + "," + e.pos.second.out+ "], taking ")
										if p.damage > e.armour then
											m.append ((p.damage - e.armour).out +" damage.%N")
										else
											m.append ("0 damage.%N")
										end
										if e.health <= 0 then
											m.append ("      The " + e.full_name + " at location ["+ model.rows[r].out + "," + c.out+ "] has been destroyed.%N")
										end
									end
								end
							elseif model.board[r,c].id = 0 then
								m.append ("      The " + e.full_name + " collides with Starfighter(id:0) at location ")
								m.append ("[" + model.rows[e.pos.first].out + "," + e.pos.second.out+ "], trading "+ e.health.out +" damage.%N")
								m.append ("      The " + e.full_name + " at location ["+ model.rows[r].out + "," + c.out+ "] has been destroyed.%N")
								model.star.collide_e (e)
							end
						end
					end

					--      The Interceptor collides with friendly projectile(id:-7) at location [A,7], taking 70 damage.
      				--		The Interceptor at location [A,7] has been destroyed.
					if e.active then
						model.board.put (e, r, c)
					end

					if model.star.destroyed then
						m.append ("      The Starfighter at location [" + model.rows[r].out + "," + c.out+ "] has been destroyed.%N")
					end
		end

		on_board(r,c:INTEGER):BOOLEAN
			do
				if r < 1 or r > model.max_r or c < 1 or c > model.max_c then
					Result := false
				else
					Result := true
				end
			end

end
