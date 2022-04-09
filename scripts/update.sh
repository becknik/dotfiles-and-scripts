#!/bin/bash

sudo --stdin emerge --sync; echo
sudo --stdin emerge -DuN --keep-going @world

flatpak update --user --assumeyes
