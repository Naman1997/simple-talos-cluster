#!/bin/bash
n=0
until [ "$n" -ge 5 ]
do
   sudo systemctl restart haproxy && break  # substitute your command here
   n=$((n+1)) 
   sleep 15
done