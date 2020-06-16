## Local Dev Virtual Box + Vagrant Setup
* [Install Virtual Box](https://www.virtualbox.org/wiki/Downloads)
* [Install Vagrant](https://www.vagrantup.com/downloads.html)
* Configure Environment
    * Clone this repo: https://github.com/lukepolo/Vagrant-LocalDev
        * It is recommended cloning this repo into a sibling folder of the intended project repo
    * In terminal change to the directory where you cloned this repo
    * Run `cp LocalDev.example.yaml LocalDev.yaml` to make a copy of the example file
    * Edit the newly created `LocalDev.yaml`
        * Update lines `6-9`, point to your local SSH key
            ```
            authorize: ~/.ssh/id_rsa.pub

            keys:
              - ~/.ssh/id_rsa
            ```
        * Update line `12`, point it to your local repo
            ```
              - map: ~/Code/work/agent
            ```
* If you want to save time when interacting with this environment it is recommended you add the following aliases to your shell; change the names to your liking
    ```
    # Call `vb {command}` to run vagrant commands
    function vb() {
        ( cd ~/location/to/project && vagrant $* )
    }
    
    # Access the Virtual Box running your project
    alias vm="ssh -t vagrant@127.0.0.1 -p 2222"
    ```
    * Be sure the function above points to your project repo.
* In your terminal run `vb up`
* Once it is finished setting up run `vm` to enter the Virtual Box environment