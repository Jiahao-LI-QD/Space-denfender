note
	description: "Summary description for {ARMOURSET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOURSET
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
			m.append ("  1:None%N" +
					"    Health:50, Energy:0, Regen:1/0, Armour:0, Vision:0, Move:1, Move Cost:0%N" +
					"  2:Light%N" +
					"    Health:75, Energy:0, Regen:2/0, Armour:3, Vision:0, Move:0, Move Cost:1%N" +
					"  3:Medium%N" +
					"    Health:100, Energy:0, Regen:3/0, Armour:5, Vision:0, Move:0, Move Cost:3%N" +
					"  4:Heavy%N" +
					"    Health:200, Energy:0, Regen:4/0, Armour:10, Vision:0, Move:-1, Move Cost:5%N")
			ms.force ("None", ms.count + 1);
			ms.force ("Light", ms.count + 1);
			ms.force ("Medium", ms.count + 1);
			ms.force ("Heavy", ms.count + 1);
		end

	display:STRING
		do
			create Result.make_from_string (m)
			Result.append (choice_message)
		end
	choice_message: STRING
		do
			create Result.make_from_string ("  Armour Selected:" + ms[answer])
		end
	valid_choice(c:INTEGER):BOOLEAN
		do
			Result := c > 0 and c <= ms.count
		end
end
