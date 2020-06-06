BEGIN{
	state=0
}
{
	switch(state){
		case 0:
			if ($4 == 1000){
				print " SIZE:",$4," CLOCK: ",$2;
				state = 1;
			}
			break;
		case 1:
			if ($4 != 1000 && $4 != 2000){
				print " SIZE: ",$4," CLOCK: ",$2;
				state = 2;
			}
			break;

		case 2:
			if ($4 == 2000){
				print " SIZE: ",$4," CLOCK: ",$2;
				state = 0;
			}
			break;
	}
}
