# MacOS Workstation Setup Ansible Playbook

This playbook started as a fork of [Jeff Geerling's mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook). At it's core the playbook still follows the same format as Jeff's. The notable changes I made are as follows:

  - Add support for Macs running on Apple silicon
  - Use asdf for packages that are likely to be used in collaboration
  - Changed the default applications to match my particular engineering needs

NOTE: This playbook isn't currently in a polished state and as such I highly recommend that you know what you are doing before you attempt to use it. YMMV.
## Installation

Update your `ansible_become_password` value in the `default.config.yml` file.

If you updated the `ansible_become_password` value to a plaintext value, then:

  1. Don't commit the file to git
  2. Update line 59 to remove the `--vault-password-file ansible-vault.pass` part of the command

I'll eventually get around to automating those tasks.

Now simply run the init script: `./init.sh`

By default this will:
  1. Install xcode command line utilities for homebrew (and so a bunch of other programs will work)
  2. Install homebrew for asdf installation
  3. Install asdf for python
  4. Install python and pip for ansible
  5. Install ansible to run the playbook
  6. Install the ansible dependencies defined in the `requirements.yml` file
  7. Ensure the user has changed installation defaults if desired
  8. Run the ansible playbook

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other Brew issue. Run `brew doctor` to see if this is the case.

### Use with a remote Mac

You can use this playbook to manage other Macs as well; the playbook doesn't even need to be run from a Mac at all! If you want to manage a remote Mac, either another Mac on your network, or a hosted Mac like the ones from [MacStadium](https://www.macstadium.com), you just need to make sure you can connect to it with SSH:

  1. (On the Mac you want to connect to:) Go to System Preferences > Sharing.
  2. Enable 'Remote Login'.

> You can also enable remote login on the command line:
>
>     sudo systemsetup -setremotelogin on

Then edit the `inventory` file in this repository and change the line that starts with `127.0.0.1` to:

```
[ip address or hostname of mac]  ansible_user=[mac ssh username]
```

If you need to supply an SSH password (if you don't use SSH keys), make sure to pass the `--ask-pass` parameter to the `ansible-playbook` command.

### Running a specific set of tagged tasks

You can filter which part of the provisioning process to run by specifying a set of tags using `ansible-playbook`'s `--tags` flag. The tags available are `dotfiles`, `homebrew`, `mas`, `extra-packages` and `osx`.

    ansible-playbook main.yml -i inventory -K --tags "dotfiles,homebrew"

## Overriding Defaults

Not everyone's development environment and preferred software configuration is the same.

You can override any of the defaults configured in `default.config.yml` by creating a `config.yml` file and setting the overrides in that file. For example, you can customize the installed packages and apps with something like:

    homebrew_installed_packages:
      - cowsay
      - git
      - go
    
    mas_installed_apps:
      - { id: 443987910, name: "1Password" }
      - { id: 498486288, name: "Quick Resizer" }
      - { id: 557168941, name: "Tweetbot" }
      - { id: 497799835, name: "Xcode" }
    
    composer_packages:
      - name: hirak/prestissimo
      - name: drush/drush
        version: '^8.1'
    
    gem_packages:
      - name: bundler
        state: latest
    
    npm_packages:
      - name: webpack
    
    pip_packages:
      - name: mkdocs

Any variable can be overridden in `config.yml`; see the supporting roles' documentation for a complete list of available variables.

## Author

Tochukwu Victor (originally inspired by [Jeff Geerling's mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook)).
