#CMake 3.12.2 Download and install
#https://github.com/Kitware/CMake/releases

#Download CMake 3.12.2
wget https://github.com/Kitware/CMake/archive/v3.12.2.tar.gz

#Unzip file
tar -zxvf v3.12.2.tar.gz

#Into CMake 3.12.2 folder
cd CMake-3.12.2

#Start install CMake 3.12.2
./bootstrap && gmake && gmake install

#Check CMake version
cmake --version

echo -e "\n\n CMake version should be 3.12.2 \n\n"
