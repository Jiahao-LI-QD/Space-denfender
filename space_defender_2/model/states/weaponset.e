note
	description: "Summary description for {WEAPONSET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WEAPONSET
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
			m.append ("  1:Standard (A single projectile is fired in front)%N" +
					"    Health:10, Energy:10, Regen:0/1, Armour:0, Vision:1, Move:1, Move Cost:1,%N" +
					"    Projectile Damage:70, Projectile Cost:5 (energy)%N" +
					"  2:Spread (Three projectiles are fired in front, two going diagonal)%N" +
					"    Health:0, Energy:60, Regen:0/2, Armour:1, Vision:0, Move:0, Move Cost:2,%N" +
					"    Projectile Damage:50, Projectile Cost:10 (energy)%N" +
					"  3:Snipe (Fast and high damage projectile, but only travels via teleporting)%N" +
					"    Health:0, Energy:100, Regen:0/5, Armour:0, Vision:10, Move:3, Move Cost:0,%N" +
					"    Projectile Damage:1000, Projectile Cost:20 (energy)%N" +
					"  4:Rocket (Two projectiles appear behind to the sides of the Starfighter and accelerates)%N" +
					"    Health:10, Energy:0, Regen:10/0, Armour:2, Vision:2, Move:0, Move Cost:3,%N" +
					"    Projectile Damage:100, Projectile Cost:10 (health)%N" +
					"  5:Splitter (A single mine projectile is placed in front of the Starfighter)%N" +
					"    Health:0, Energy:100, Regen:0/10, Armour:0, Vision:0, Move:0, Move Cost:5,%N" +
					"    Projectile Damage:150, Projectile Cost:70 (energy)%N")
				ms.force ("Standard", ms.count + 1);
				ms.force ("Spread", ms.count + 1);
				ms.force ("Snipe", ms.count + 1);
				ms.force ("Rocket", ms.count + 1);
				ms.force ("Splitter", ms.count + 1);
		end

	display:STRING
		do
			create Result.make_from_string (m)
			Result.append (choice_message)
		end
	choice_message: STRING
		do
			create Result.make_from_string ("  Weapon Selected:")
			Result.append (ms[answer])
		end
	valid_choice(c:INTEGER):BOOLEAN
		do
			Result := c > 0 and c <= ms.count
		end
end
