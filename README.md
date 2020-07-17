For this Project i have launch infrastructure through Terraform as code was provide above i have created a VPC, Route table, Route53, Ec2(Ubuntu 18.04), 2 public subnets Internet gateway and Elastic Load balancer 

once we ssh into the machine it came up with the docker and nginx server installed in a container as we already mentioned in the script along with the terraform 

My goal in this project is to server the static content in a text file which shows the version Num 1.0.6 for achieving this i need to make some changes in the nginx configuration file as we already know by default ngnix goes to the /var/www/html looks for the static content in this path we add a directory named version and add index.txt file which serves our version num after this i chaged the configuration in /etc/ngnix/sites-enabled editing the default file by adding our version directory and index.txt. restart the ngnix server we come up with version num 1.0.6

i have created bash script, i've made it periodically the script runs every 6 sceconds and checks whether the nginx server is up and serving with version num

for achieving SSL certificates i used certbot commnads, i made my container to run on 90 port i enabled nginx reverse proxy in host machine, so it directs the traffic recieve from host machine to the container port 


note : please find the screenshots atatached in the screenshot folder 
