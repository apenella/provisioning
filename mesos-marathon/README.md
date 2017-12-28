# Mesos Marathon
Mesos Marathon environment provides a Mesos stack with the marathon framework deployed on it.

## Preconditions
This environment has been prepared using:
- Vagrant version 1.8.7
- Vagrant box ```trusty64```

## Usage
The environment could be set up to have an minum, medium or maximum deployment, either for master nodes or slaves ones.

The minimum deployment creates one node, whereas the medium creates three and maximum five. It is possible to change the deployment size modifing ```$MESOS_MASTER_DEPLOYMENT``` and ```$MESOS_SLAVE_DEPLOYMENT``` variables values, on ```Vagrantfile```.

Once the ```Vagrantfile``` is modified with the desired deployment size, you could create and start mesos-marathon environment executing the below command.

```shell
vagrant up
```

After a while, the environment is already deployed and you could manage Marathon using the web user interface on http://10.0.0.11:8080 and Mesos on http://10.0.0.11:5050.

## References
- [https://mesosphere.github.io/marathon/docs/](https://mesosphere.github.io/marathon/docs/)
- [http://www.swisspush.org/clustering/2014/12/05/install-mesos-on-singlenode](http://www.swisspush.org/clustering/2014/12/05/install-mesos-on-singlenode)
- [https://www.digitalocean.com/community/tutorials/an-introduction-to-mesosphere](https://www.digitalocean.com/community/tutorials/an-introduction-to-mesosphere)


## Author

Author:: Aleix Penella (aleix.penella@gmail.com)
