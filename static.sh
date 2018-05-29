#!/bin/bash

port=7081

pid=$(ss -lp|grep $port|sed "s/.*pid=//g"|sed "s/,.*//g")
if [[ ${#pid} != 0 ]];then
    kill $pid
fi

git pull
hexo g
nohup http-server -p $port &
