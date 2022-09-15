note
	description: "Summary description for {POWERSET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POWERSET

inherit
	STATE
		redefine
			make
		end
create
	make

feature
	make
		do
			Precursor
			ms.force ("Recall (50 energy): Teleport back to spawn.", ms.count + 1);
			ms.force ("Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.", ms.count + 1);
			ms.force ("Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.", ms.count + 1);
			ms.force ("Deploy Drones (100 energy): Clear all projectiles.", ms.count + 1);
			ms.force ("Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.", ms.count + 1);
			across 1 |..| ms.count is c loop m.append ("  " + c.out + ":" + ms[c] + "%N") end
		end

	display:STRING
		do
			create Result.make_from_string (m)
			Result.append (choice_message)
		end
	choice_message: STRING
		do
			create Result.make_from_string ("  Power Selected:" + ms[answer])
		end
	valid_choice(c:INTEGER):BOOLEAN
		do
			Result := c > 0 and c <= ms.count
		end
end
