require 'bundler/setup'
require 'aws-sdk-cloudwatch'
require 'puma-plugin-cloudwatch'

bind "tcp://127.0.0.1:9292"
workers 1
threads 8, 16
plugin :cloudwatch
