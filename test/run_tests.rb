#!/usr/bin/env ruby

# Test runner for Claude JIRA integration tests
require 'bundler/setup'
require 'minitest/autorun'

# Require all test files
test_files = Dir[File.join(__dir__, 'test_*.rb')]
test_files.each { |file| require file }

puts "Running #{test_files.length} test files..."
puts "Test files: #{test_files.map { |f| File.basename(f) }.join(', ')}"