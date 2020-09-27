# Airflow server on Raspberry Pi using Ansible

This project uses Ansible to install Airflow on a single Raspberry Pi, using [LocalExecutor](https://airflow.apache.org/docs/stable/executor/) backed by a [Postgres database](https://www.postgresql.org).


## Software components

The project includes the following software components:

- **Airflow Docker image** built from the Dockerfile provided in this repository.
- **Airflow Docker container** running a single-node Airflow instance using LocalExecutor backed by Postgres.
- **Postgres Docker container** running a Postgres instance to back Airflow.
- **Bridge Docker network** to run the two above containers in isolation.

The project has been tested on Raspberry Pi 3B+ and 4B. 


## Prerequisite

1. Python3 installed on control and managed nodes.
2. Ansible is installed on the control node.
3. Ensures ssh ports on control and managed are open.

## Usage


1. Install required roles on the control node:

	```
	ansible-galaxy install -r requirements.yml --roles-path ./roles
	```

2. Configure ``inventory`` file as needed.
 
3. Change default variables as defined in playbooks and in ``./roles/*/defaults/main.yml`` to accomodate your deployment.

4. Perform basic setup of managed nodes, e.g. enabling i2c, setting up required users: 

	```
	ansible-playbook playbook_machines_setup.yml
	```


5. Install Airflow and Postgres backend. 

	```
	ansible-playbook playbook_airflow.yml
	```

   The playbook will do the following:
        
   - copy Airflow Dockerfile and entrypoint.sh to control node.
   - build Airflow Docker image on control node based on Dockerfile.
   - setup dedicated bridge Docker network.
   - run Postgres container and connect it to the bridge network.
   - run Airflow container based on created image and connect it to the bridge network. The entrypoint will initialize the database, start the scheduler and the webserver


The Airflow UI should now be available on port 8080 of your control node.
