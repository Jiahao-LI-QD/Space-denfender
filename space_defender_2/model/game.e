note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	GAME

inherit
	ANY
		redefine
			out
		end

create {GAME_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
--			create s.make_empty
--			i := 0
			create {LINKED_LIST[INTEGER]} thresholds.make
			debug_mode := false
			create state.make
			create error.make
			create star.make(1,1)
			create {LINKED_LIST[ENEMY]} enemies.make
			create {LINKED_LIST[PROJECTILE]} projs.make
			create board.make_filled (create {OBJECT}.make, 1, 1)
			rows:= <<'A','B','C','D','E','F','G','H','I','J'>>
			--
			create m_e_proj.make_empty
			create m_enemies.make_empty
			create m_spawn.make_empty
			create m_f_proj.make_empty
			create m_star.make_empty
--			create memory.make_filled (1, 1, 4)
		end

feature -- model attributes
--	s : STRING
--	i : INTEGER
	random: RANDOM_GENERATOR_ACCESS
	max_r: INTEGER
	max_c: INTEGER
	thresholds: LIST[INTEGER]

feature -- board objects
	star: STARFIGHTER
	enemies: LIST[ENEMY]
	projs: LIST[PROJECTILE]
	board: ARRAY2[OBJECT]
	rows: ARRAY[CHARACTER]
feature -- game state
	exited: BOOLEAN
	debug_mode: BOOLEAN
	debug_toggled: BOOLEAN

feature -- debug information
--  SECTION 2: ENEMY
--  SECTION 3: PROJECTILE
--  SECTION 4: FRIENDLY PROJECTILE ACTION
--  SECTION 5: ENEMY PROJECTILE ACTION
--  SECTION 6: STARFIGHTER ACTION
--  SECTION 7: ENEMY ACTION
--  SECTION 8: NATURAL ENEMY SPAWN
	m_f_proj: STRING
	m_e_proj: STRING
	m_star: STRING
	m_enemies: STRING
	m_spawn: STRING

feature -- debug update
	update_f_act(s:STRING)
		do
			if m_f_proj.is_empty then
				m_f_proj.append ("  Friendly Projectile Action:%N")
			end
			m_f_proj.append (s)
		end

	inf_f_proj_display: STRING
		do
			create Result.make_empty
			if m_f_proj.is_empty then
				Result.append( "  Friendly Projectile Action:%N")
			else
				Result.append (m_f_proj)
				m_f_proj.wipe_out
			end
		end
--------------------------------------
	update_e_act(s:STRING)
		do
			if m_e_proj.is_empty then
				m_e_proj.append ("  Enemy Projectile Action:%N")
			end

				m_e_proj.append (s)
		end

	inf_e_proj_display: STRING
		do
			create Result.make_empty
			if m_e_proj.is_empty then
				Result.append( "  Enemy Projectile Action:%N")
			else
				Result.append (m_e_proj)
				m_e_proj.wipe_out
			end
		end
-----------------------------------------
	update_star_act(s:STRING)
		do
			if m_star.is_empty then
				m_star.append ("  Starfighter Action:%N")
			end

				m_star.append (s)
		end

	inf_star_display: STRING
		do
			create Result.make_empty
			if m_star.is_empty then
				Result.append( "  Starfighter Action:%N")
			else
				Result.append (m_star)
				m_star.wipe_out
			end
		end
------------------------------------------------------------------
	update_enemies_act(s:STRING)
		do
			if m_enemies.is_empty then
				m_enemies.append ("  Enemy Action:%N")

			end

				m_enemies.append (s)
		end

	inf_enemies_display: STRING
		do
			create Result.make_empty
			if m_enemies.is_empty then
				Result.append( "  Enemy Action:%N")
			else
				Result.append (m_enemies)
				m_enemies.wipe_out
			end
		end
---------------------------------------------------------
	update_spawn_act(s:STRING)
		do
			if m_spawn.is_empty then
				m_spawn.append ("  Natural Enemy Spawn:%N")

			end
				m_spawn.append (s)
		end

	inf_spawn_display: STRING
		do
			create Result.make_empty
			if m_spawn.is_empty then
				Result.append( "  Natural Enemy Spawn:%N")
			else
				Result.append (m_spawn)
				m_spawn.wipe_out
			end
		end

feature -- setup state
--	memory: ARRAY[INTEGER]
	state: STATE_TRANSACTION
	in_game: BOOLEAN
	started: BOOLEAN
	nb_action: INTEGER

	-- 1 pass // 2 fire // 3 move // 4 special
	action_type: INTEGER
feature -- error handler
	error: ERROR
feature -- model operations
	default_update
			-- Perform update to the model state.
		do
--			i := i + 1
		end

	reset
			-- Reset model state.
		do
			make
		end

feature -- ingame phase
	new_action
		do
			nb_action := nb_action + 1
			error.reset
		end

	vision_update
		do
			across enemies is e loop e.update_vision end
		end

	f_projs_move
		do
			across projs is p loop
				if p.active and p.type > 0 and not star.destroyed then
					p.move
				end
			end
		end

	e_projs_move
		do
			across projs is p loop
				if p.active and p.type = 0 and not star.destroyed then
					p.move
				end
			end
		end

	enemies_ready
		do
			across enemies is e loop
				e.set_ready
			end
		end

	enemies_action
		require
			in_game: in_game
			game_not_over: not star.destroyed
		do
			across enemies is e loop
				if e.active and e.ready and not star.destroyed then
					e.preemptive_action
				end
			end
			across enemies is e loop
				if e.active and e.ready and not star.destroyed then
					e.action
				end
			end
		ensure
			case_star_destroyed: star.destroyed implies star.health = 0
		end

	enemy_spawn
		local
			t1, t2: INTEGER
			e: ENEMY
			m: STRING
			not_generated: BOOLEAN
		do
			create m.make_empty
			t1 := random.rchoose (1, max_r)
			t2 := random.rchoose (1, 100)
			if board[t1,max_c].id <= 0 then
				if t2 >= 1 and t2 < thresholds[1] then
					create {GRUNT} e.make (enemies.count + 1, t1, max_c)
				elseif t2 >= thresholds[1] and t2 < thresholds[2] then
					create {FIGHTER} e.make (enemies.count + 1, t1, max_c)
				elseif t2 >= thresholds[2] and t2 < thresholds[3] then
					create {CARRIER} e.make (enemies.count + 1, t1, max_c)
				elseif t2 >= thresholds[3] and t2 < thresholds[4] then
					create {INTERCEPTOR} e.make (enemies.count + 1, t1, max_c)
				elseif t2 >= thresholds[4] and t2 < thresholds[5] then
					create {PYLON} e.make (enemies.count + 1, t1, max_c)
				else
					not_generated := true
				end

				if not not_generated then
					if attached e as l_e then
						enemies.extend (l_e)
						if not board[t1,max_c].occupied then
							board.put (l_e, t1, max_c)
						else
							if  board[t1,max_c].id < 0 then
								check attached {PROJECTILE} board[t1, max_c] as p then
								l_e.collide (p)
									if p.type = 0 then
										m.append ("      The " + l_e.full_name + " collides with enemy projectile(id:" + p.id.out +") at location ")
										m.append ("[" + rows[l_e.pos.first].out + "," + l_e.pos.second.out+ "], healing "+p.damage.out +" damage.%N")
									else
										m.append ("      The " + l_e.full_name + " collides with friendly projectile(id:" + p.id.out +") at location ")
										m.append ("[" + rows[l_e.pos.first].out + "," +l_e.pos.second.out+ "], taking "+(p.damage - l_e.armour).out +" damage.%N")
									end
								end
								if l_e.active then
									board.put (l_e, t1, max_c)
								end
							elseif board[t1,max_c].id = 0 then
								m.append ("      The " + l_e.full_name + " collides with Starfighter(id:0) at location ")
								m.append ("[" + rows[l_e.pos.first].out + "," + l_e.pos.second.out+ "], trading "+ l_e.health.out +" damage.%N")

								star.collide_e (l_e)
							end
						end
						if not l_e.active then
							m.append ("      The " + l_e.full_name + " at location ["+ rows[l_e.pos.first].out + "," + l_e.pos.second.out+ "] has been destroyed.%N")
						end
						if star.destroyed then
							m.append ("      The Starfighter at location [" + rows[l_e.pos.first].out + "," + l_e.pos.second.out+ "] has been destroyed.%N")

						end
						update_spawn_act ("    A " + l_e.full_name)
						update_spawn_act ("(id:" + l_e.id.out + ") spawns at location [" + rows[l_e.pos.first].out + "," + l_e.pos.second.out+ "].%N")
						update_spawn_act (m)
					end


				end

			end
		end

feature -- command
	play(m_r: INTEGER; m_c:INTEGER; t1: INTEGER; t2: INTEGER; t3: INTEGER; t4: INTEGER; t5: INTEGER)
		require
		do
			max_r:= m_r
			max_c:= m_c
			thresholds.wipe_out
			thresholds.extend (t1)
			thresholds.extend (t2)
			thresholds.extend (t3)
			thresholds.extend (t4)
			thresholds.extend (t5)
			projs.wipe_out
			enemies.wipe_out
			create board.make_filled (create {OBJECT}.make, max_r, max_c)
			started:= true
			in_game:= false
			state.reset --(memory)
			error.reset
			star.reset
			nb_action := 0
		end

	pass
		do
			action_type:=1
			new_action
			f_projs_move
			if not star.destroyed then
				e_projs_move
			end
			if not star.destroyed then
				star.pass
			end
			if not star.destroyed then
				vision_update
				enemies_action
			end
			if not star.destroyed then
				vision_update
				enemies_ready
				enemy_spawn
			end
		end

	fire
		do
			action_type:=2
			new_action
			f_projs_move
			if not star.destroyed then
				e_projs_move
			end
			if not star.destroyed then
				star.fire
			end
			if not star.destroyed then
				vision_update
				enemies_action
			end
			if not star.destroyed then
				vision_update
				enemies_ready
				enemy_spawn
			end
		end

	move(r, c: INTEGER)
		do
			action_type:=3
			new_action
			f_projs_move
			if not star.destroyed then
				e_projs_move
			end
			if not star.destroyed then
				star.move_to (r, c)
			end
			if not star.destroyed then
				vision_update
				enemies_action
			end
			if not star.destroyed then
				vision_update
				enemies_ready
				enemy_spawn
			end
		end

	special
		do
			action_type:=4
			new_action
			f_projs_move
			if not star.destroyed then
				e_projs_move
			end
			if not star.destroyed then
				star.special
			end
			if not star.destroyed then
				vision_update
				enemies_action
			end
			if not star.destroyed then
				vision_update
				enemies_ready
				enemy_spawn
			end
		end

	abort
		do
			error.reset
			exited := true
			started := false
		end

	toggle_ingame
		do
			in_game:= true
				nb_action := 0
				star.equip
				error.reset
				board.put (star, star.pos.first, star.pos.second)

		end

	toggle_started
		do
			started:= false
		end

	toggle_debug
		do
			debug_toggled:= true
			debug_mode :=  not debug_mode
			error.debug_mode
		end


feature -- queries

	enemies_display: STRING
		do
			create Result.make_from_string("  Enemy:%N")
			across enemies is e loop
				if e.active then
					Result.append(e.display)
				end
			end
		end

	projs_display: STRING
		do
			create Result.make_from_string("  Projectile:%N")
			across projs is p loop
				if p.active then
					Result.append(p.display)
				end
			end
		end

	board_display: STRING
		do
			create Result.make_from_string("    ")
			across 1 |..| max_c is l_i loop
				if l_i < 10 then
					Result.append("  " + l_i.out)
				else
					Result.append(" " + l_i.out)
				end
			end
			Result.append("%N")

			across 1 |..| max_r is r loop
				Result.append ("    " + rows[r].out)
				across 1 |..| max_c is c loop
					if c = 1 then
						Result.append(" ")
					else
						Result.append("  ")
					end
					if debug_mode then
						Result.append(board[r,c].out)
					else
						if star.in_vision (r, c) then
							Result.append(board[r,c].out)
						else
							Result.append ("?")
						end
					end
				end
				if r /= max_r then
					Result.append("%N")
				end
			end
		end

	debug_display: STRING
		do
			create Result.make_empty
			if debug_mode then
				Result.append ("  In debug mode.")
			else
				Result.append ("  Not in debug mode.")
			end
			debug_toggled := false
		end

	exited_display: STRING
		do
			create Result.make_empty
			if not in_game then
				Result.append ("  Exited from setup mode.")
			else
				Result.append ("  Exited from game.")
			end
			exited := false
		end

	title : STRING
		do
			create Result.make_from_string ("  state:")
			if not started or star.destroyed then
				Result.append("not started")
			elseif in_game then
				Result.append ("in game(" + nb_action.out + "." + error.state.out + ")" )
			else
				if state.state_cursor = 1 then
					Result.append ("weapon setup")
				elseif state.state_cursor = 2 then
					Result.append ("armour setup")
				elseif state.state_cursor = 3 then
					Result.append ("engine setup")
				elseif state.state_cursor = 4 then
					Result.append ("power setup")
				elseif state.state_cursor = 5 then
					Result.append ("setup summary")
				end
			end

				Result.append(", ")

			if debug_mode then
				Result.append("debug")
			else
				Result.append("normal")
			end

				Result.append(", ")

			if error.state = 0 or debug_toggled then
				Result.append("ok%N")
			else
				Result.append("error%N")
			end
		end


	out : STRING
		do
			create Result.make_empty
			Result.append (title)
			if error.state /= 0 and not debug_toggled then
				Result.append (error.message)
			elseif debug_toggled then
				Result.append (debug_display)
			elseif exited then
				Result.append (exited_display)
				in_game:= false
			elseif not started then
				Result.append("  Welcome to Space Defender Version 2.")
			elseif not in_game then
				Result.append (state.state_display)
			else
				Result.append (star.display)
				if debug_mode then
					Result.append(enemies_display)
					Result.append(projs_display)
					Result.append(inf_f_proj_display)
					Result.append(inf_e_proj_display)
					Result.append(inf_star_display)
					Result.append(inf_enemies_display)
					Result.append(inf_spawn_display)
				end
					inf_f_proj_display.wipe_out
					inf_e_proj_display.wipe_out
					inf_star_display.wipe_out
					inf_enemies_display.wipe_out
					inf_spawn_display.wipe_out
				Result.append (board_display)
				if star.destroyed then
					Result.append ("%N  The game is over. Better luck next time!")
					started := false
					in_game := false
				end
			end
		end

end




