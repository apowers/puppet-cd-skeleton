puppet-cd-skeleton
==================

Skeleton for Puppet with Continuous Deployment

**NOTICE: This is very much a work in progress. Bugs abound.**

Setup
------

### Requirements
* Ubuntu LTS (Tested on 14.04)
* Git
* Connection to the Internet

### Installation
1. Clone this repository to `/opt/puppet-cd-skeleton`
1. Install development tools: `bin/setup_puppet_development.sh`
1. Provision the system with the role "cd_demo": `bin/provision-standalone.sh cd_demo`.
1. Browse to the host with a browser of your choice.

**WARNING: The installation has no security features enabled. No operations are secured with passwords or anything else.**

Operation
------
When committing changes to the git repo:
1. The pre-commit hook will perform a `rake validate`.
1. The post-commit hook will send a signal, via curl, to jenkins at localhost:80 to build the puppet-cd_demo project.
1. Jenkins will run `bin/puppet-integration-test.sh cd_demo`, which spawns a docker instance to test the role "cd_demo".
