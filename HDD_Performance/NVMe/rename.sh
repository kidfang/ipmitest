for file in `ls | grep .txt`
do
newfile=`echo $file | sed 's/:/_/g'`
mv $file $newfile
done
