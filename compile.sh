#!/bin/bash

# for local building while I write this software
gcc-mp-8 -Wall -O3 -std=c99 -fstack-protector-all -o onetime onetime.c
