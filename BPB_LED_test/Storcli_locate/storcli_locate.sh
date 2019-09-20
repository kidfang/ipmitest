for (( i=0; i<=1; i=i+1 ));
	do
		echo -e "\nInput EID number:\n"
		read eid_num
		
	for (( k=0; k<=29; k=k+1 ));
		do
		
		/opt/MegaRAID/storcli/storcli64 /c$i /e"$eid_num" /s$k start locate

		echo -e "\n"
		read -n 1 -p "Check locate correct or not ..."

		/opt/MegaRAID/storcli/storcli64 /c$i /e"$eid_num" /s$k stop locate
		
		done
	done
