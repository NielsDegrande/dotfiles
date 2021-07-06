#!/bin/bash

if [ $(pgrep Amethyst) ]
then
    pkill Amethyst
fi
open /Applications/Amethyst.app
