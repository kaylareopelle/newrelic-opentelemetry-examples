#!/bin/bash

while :
do
  echo "Calling fibonacci-ruby"

  echo "GET http://localhost:8080/fibonacci?n=5"
  curl "http://localhost:8080/fibonacci?n=5" || true
  echo

  echo "GET http://localhost:8080/fibonacci?n=283"
  curl "http://localhost:8080/fibonacci?n=283" || true
  echo

  echo "GET http://localhost:8080/fibonacci?n=10"
  curl "http://localhost:8080/fibonacci?n=10" || true
  echo

  echo "GET http://localhost:8080/fibonacci?n=90"
  curl "http://localhost:8080/fibonacci?n=90" || true
  echo

  echo "GET http://localhost:8080/fibonacci?n=0"
  curl "http://localhost:8080/fibonacci?n=0" || true
  echo

  sleep 2
done
