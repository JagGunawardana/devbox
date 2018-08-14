#!/usr/bin/env bash

# Useful script to watch for changes and then run tests

if [ $# -lt 2 ]; then
    echo "Usage $0 dir_to_watch tests_to_run [debug command]"
    exit 1
fi

dirname=$1
lockfile=`tempfile`
debug_command=""

tests_to_run=$2
shift 2

other_args="$@"

echo "Watch dir: $dirname"
echo "Tests to run: $tests_to_run"
echo "Args: $other_args"
echo "Using py.test " `which py.test`

touch $lockfile

while true
do
    new_files=`find $dirname -type f -newer $lockfile -name "*.py"`
    if [ ${#new_files} -gt 0 ]; then
        py.test -s $other_args $tests_to_run || echo -e "\a"
    fi
    touch $lockfile
    sleep 1
done

