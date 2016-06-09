# update the hosts files
sudo cp /vagrant/hosts.txt /etc
sudo mv /etc/hosts.txt /etc/hosts

echo "Adding puppet repo"
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
echo "Adding drbd repo"
sudo rpm -ivh http://elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
echo "Adding mysql repo"
sudo rpm -ivh https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
echo "installing puppet"
sudo yum install -y puppet
