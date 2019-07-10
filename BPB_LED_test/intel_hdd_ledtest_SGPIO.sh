#!/bin/bash
ls /sys/class/block|grep sd|while read d ; do ledctl locate=/dev/$d ; sleep 2 ; ledctl normal=/dev/$d ; sleep 2 ; done
ls /sys/class/block|grep sd|while read d ; do ledctl rebuild=/dev/$d ; sleep 2 ; ledctl normal=/dev/$d ; sleep 2 ; done
ls /sys/class/block|grep sd|while read d ; do ledctl disk_failed=/dev/$d ; sleep 2 ; ledctl normal=/dev/$d ; sleep 2 ; done
