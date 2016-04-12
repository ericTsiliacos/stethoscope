# Setting up concourse
## Vagrant
Download and install [Vagrant](https://www.vagrantup.com/)

```
vagrant init concourse/lite
vagrant up
```

## Adding worker
Get `host_key.pub` and `worker_key` from Vagrant VM with:
```
vagrant ssh -c "cat /opt/concourse/host_key.pub" > host_key.pub
vagrant ssh -c "sudo cat /opt/concourse/worker_key" > worker_key
```
Download standalone [Concourse binary](http://concourse.ci/binaries.html)
Run:

```
sudo ./concourse worker \
  --work-dir /opt/concourse/worker \
  --peer-ip WORKER_IP_ADDRESS \
  --tsa-host 192.168.100.4 \
  --tsa-public-key host_key.pub \
  --tsa-worker-private-key worker_key
```

## Setting up Fly-Cli
Install fly-cli from your concourse web UI and run:
```
fly -t lite login -c http://192.168.100.4:8080
fly sp -n -t lite -p stethoscope -c .pipeline.yml
fly up -t lite -p stethoscope
```
