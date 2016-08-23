#!/bin/bash

bundle exec ./nypl_recrop.rb $1 && ./run-torchwarp.sh $1
