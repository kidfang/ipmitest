echo -e "\nFor install DLBS enviroment into Centos 7, please check your OS is Centos first!"
echo -e "\nPlease input the install item (docker-ce, nvidia-docker, build-tool): "
echo -e "\nSuggest install order => docker-ce, nvidia-docker, build-tool"
read install

#Install docker-ce

docker-ce()

{

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2


sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io -y

sleep 5

sudo systemctl start docker

sleep 5

sudo docker run hello-world

}

nvidia-docker()

{

distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | \
  sudo tee /etc/yum.repos.d/nvidia-docker.repo

sudo yum install -y nvidia-docker2

sleep 5

sudo pkill -SIGHUP dockerd


echo -e "\nTest nvidia-smi with the latest official CUDA image"

sleep 5

docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi

echo -e "\nIf fail and return as follows"
echo -e "\ndocker: Error response from daemon: OCI runtime create failed: "
echo -e "\nPlease type: sudo nvidia-persistenced"

sleep 5

}

build-tool()

{

sudo yum -y install gcc-gfortran
sudo yum -y install blas-devel
sudo yum -y install lapack-devel
sudo yum -y install python-devel

yum -y install epel-release
yum -y install python-pip

sudo pip install numpy

sudo yum -y install freetype-devel.x86_64
sudo yum -y install libpng-devel.x86_64

sudo yum -y install gcc-c++
gcc --version
g++ --version

sudo pip install pandas

sudo yum -y install freetype-devel
sudo yum -y install libpng-devel

echo -e "\nPlease check pyparsing version by following website"
echo -e "\nhttps://pypi.org/project/pyparsing/"
echo -e "\nPlease type the pyparsing version! ex. 2.4.0"
read ver

sudo pip install -I pyparsing==$ver     
sudo pip install matplotlib

}

#test()

#{

#a=2.4.0
#echo "$a"

#echo "type now"
#read a

#echo "$a"

#}

case ${install} in

	"docker-ce")
		echo "Start install docker-ce ..."
		docker-ce 1
		;;

        "nvidia-docker")
                echo "Start install nvidia-docker ..."
                nvidia-docker 1
                ;;
        "build-tool")
                echo "Start build tool ..."
                build-tool 1
                ;;

#	"test")
#		test 1
#		;;
esac

