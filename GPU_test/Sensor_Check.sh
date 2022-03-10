file1=ipmi_sensor_idle.txt
file2=ipmi_sensor_stress.txt

awk '{print $1 " " $3 " " "&"}' $file1 > 1.txt
awk '{print $3 " " $5}' $file2 > 2.txt
awk 'NR==FNR{a[i]=$0;i++}NR>FNR{print a[j]" "$0;j++}' 1.txt 2.txt > 3.txt

cat 3.txt | grep -i gpu | awk '{print $1}'
cat 3.txt | grep -i gpu | awk '{print $2 " " $3 " " $4 " " $5 " " "(idle Status & loading Status))" }'


### 1.txt , Catch Sensor name and idle sensors value add & at all the last word
### 2.txt , Catch stress sensors value 
### 3.txt , 1.txt + 2.txt
