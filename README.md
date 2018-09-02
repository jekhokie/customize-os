# Customize OS

A small repository containing scripts and Ansible playbooks to customize the operating system
to my liking. There are some gross assumptions made and this is optimized for an Ubuntu 16.04
installation/may not work in other environments.

## To Run

In order to run this configuration utility, run the root script which will prompt for a few
optional components followed by executing the Ansible playbook which should bring the system
to the desired state/customization:

```bash
$ sudo ./kickoff.sh
```

The script will first execute some prerequisites such as checking for network connectivity,
asking about wifi drivers (as I had some issues with an older Dell XPS 420 system regarding
wifi drivers within an Ubuntu 16.04 installation), and then execute the Ansible playbook which
will bring the system to the state I expect.

If you wish to run in order to just bring things into alignment based on updates to the Ansible
playbooks, simply run the following command (extra-args are to be updated based on desire):

```bash
$ sudo ansible-playbook provision-local.yml --extra-vars "user_id=jkarimi user_home=/home/jkarimi"
```

It's incredibly important to utilize "sudo" for the `ansible-playbook` command due to the fact that
at the time of this utility creation, there is a race condition for sudo privilege acceptance that
fails when attempting to run playbooks containing `with_items` statements.
