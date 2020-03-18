#!/bin/bash
rm -rf /dev/shm/zero.txt
dd if=/dev/zero of=/dev/shm/zero.txt bs=1M count=50
