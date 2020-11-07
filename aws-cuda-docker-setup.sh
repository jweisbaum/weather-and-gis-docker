sudo yum update -y
sudo yum install git -y
sudo amazon-linux-extras install docker
sudo systemctl enable docker \
   && sudo systemctl start docker
sudo usermod -a -G docker ec2-user
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
sudo yum clean expire-cache
sudo systemctl restart docker
git checkout https://github.com/jweisbaum/weather-and-gis-docker
cd weather-and-gis-docker
docker build .
