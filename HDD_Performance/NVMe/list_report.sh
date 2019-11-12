ls -l | grep read | cut -f 2 -d "_" > list_r.txt
ls -l | grep write | cut -f 2 -d "_" > list_w.txt

cat read_*.txt | grep READ: | cut -f 1 -d "," > REaD_simple_list.txt
cat write_*.txt | grep WRITE: | cut -f 1 -d "," > WRiTe_simple_list.txt

r=$(cat list_r.txt | wc -l)
w=$(cat list_w.txt | wc -l)

for (( i=1; i<=$r; i=i+1 ));
	do
		Z=$(sed -n "$i"p list_r.txt)
		N=$(sed -n "$i"p REaD_simple_list.txt)
		echo "$Z $N" >> READ_report_list.txt
	done


for (( i=1; i<=$w; i=i+1 ));
	do
		Y=$(sed -n "$i"p list_w.txt)
		M=$(sed -n "$i"p WRiTe_simple_list.txt)
		echo "$Y $M" >> WRITE_report_list.txt
	done

rm list_r.txt -f
rm list_w.txt -f
rm REaD_simple_list.txt -f
rm WRiTe_simple_list.txt -f
