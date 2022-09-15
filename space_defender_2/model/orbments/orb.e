note
	description: "Summary description for {ORB}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ORB

inherit
	ORBMENT

feature
	s: INTEGER

	make
		deferred
		end

	value:INTEGER
		do
			Result := s
		end

end
