#!/bin/bash

if [ "$1" == "make" ]; then
    make TARGET=main
    make TARGET=task1
    make TARGET=task2
    make TARGET=task3
elif [ "$1" == "clean" ]; then
    make TARGET=main clean
    make TARGET=task1 clean
    make TARGET=task2 clean
    make TARGET=task3 clean
else
    echo "input build.sh make|clean only."
fi
