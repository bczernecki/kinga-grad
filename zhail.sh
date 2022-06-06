#!/bin/bash


cd data/zhail

for i in *zhail
    do
	echo $i
	../../RainBlob -expand $i
done
