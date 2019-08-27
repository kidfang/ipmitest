
mst start

vp_id=$(ibv_devinfo | grep -i vendor_part_id | awk '{print $2}'| sed -n '1p')

echo -e "\n------------------------\n"

mlxconfig -d /dev/mst/mt"$vp_id"_pciconf0 q | grep -i LINK_TYPE
lan_num=$(mlxconfig -d /dev/mst/mt"$vp_id"_pciconf0 q | grep -i LINK_TYPE | wc -l)

echo -e "\n------------------------\n"

echo -e "\nAbove are the LINK_TYPE now\nPlease input the LINK_TYPE you want: InfiniBand=1, Ethernet=2\n"
read LT_mode

for (( i=1; i<="$lan_num"; i=i+1 ));
	do
		mlxconfig -d /dev/mst/mt"$vp_id"_pciconf0 set LINK_TYPE_P"$i"="$LT_mode"
	done

echo -e "\n------------------------\n"

mlxconfig -d /dev/mst/mt"$vp_id"_pciconf0 q | grep -i LINK_TYPE

echo -e "\n------------------------\n"
