#!/bin/bash

ps -ef | grep pbench | grep fio | awk '{print $2}' | while read i; do kill "$i"; done