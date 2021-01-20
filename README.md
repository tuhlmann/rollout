# Rollout

Simple Bash helper functions to automate Linux distribution customization

## Why

I needed a simple tool to help me automate certain installation steps after setting up a new linux machine.

There are a number of very elaborate and great tools out there that already do that any much more. For my use case that was just too complicated. Also, I didn't want to have any dependencies I'd need to install first in order to use these tools.

## What is it

I created a few Bash helper functions that I can access from a playbook bash script to create basically a nicer to read Bash script to help me install packages, settings, etc. on a local machine.

It is not meant to be used on remote machines or to automate the creation of 20 identical servers- Ansible is one of the great tools that does a much better job on that.

## How

As of now, [download](https://github.com/tuhlmann/rollout/archive/main.zip) the `rollup` archive and extract it.
Select one of the playbook files (like `pop_os_2004.sh`), andapt it to your needs and run it.

The playbook files are meant to be idempotent, you should be able to run them multiple times without any additional side effects (like adding a repository multiple times).