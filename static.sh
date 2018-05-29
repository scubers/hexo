#!/bin/bash

git pull
hexo g
nohup http-server -p 7081 &
