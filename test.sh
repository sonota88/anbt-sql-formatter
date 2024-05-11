#!/bin/bash

set -o errexit

(
  cd test
  for file in $(ls test_*.rb); do
    bundle exec ruby $file
  done
)
