#!/bin/bash

while true; do
    rm -rf ~/.cache/cmake_tools_nvim/homeossedevdep* build
    nvim '+CMakeSelectCwd main' main/main.cpp || break
done
