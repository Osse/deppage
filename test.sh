#!/bin/bash

while true; do
    rm -rf ~/.cache/cmake_tools_nvim/homeossedevdep*
    rm -rf bygge build
    nvim '+CMakeSelectCwd main' || break
done
