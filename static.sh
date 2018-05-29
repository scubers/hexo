#!/bin/bash

git pull
hexo s
nohup http-server -p 7081 &
