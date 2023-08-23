#!/bin/bash
n=0
retries=5

until [ "$n" -ge "$retries" ]; do
   if sudo systemctl restart haproxy; then
      exit 0
   else
      n=$((n+1)) 
      sleep 5
   fi
done

echo "All retries failed. Exiting with code 1."
exit 1
