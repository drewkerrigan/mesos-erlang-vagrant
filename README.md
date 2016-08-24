# mesos-erlang-vagrant
Vagrant + Mesos 0.26 + Erlang R16B02 + Marathon + ZK + Mesos-DNS

# Usage

Bring up the VM and install Mesos, Erlang, Marathon, Zookeeper, and Mesos-DNS

```
git clone https://github.com/drewkerrigan/mesos-erlang-vagrant.git
cd mesos-erlang-vagrant/ubuntu/xenial
vagrant up
```

Verify everything works as expected

```
vagrant ssh
curl http://master.mesos:5050
```
