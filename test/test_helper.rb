# frozen_string_literal: true
require 'simplecov'            # These two lines must go first
SimpleCov.start
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'katakata_irb'

require 'minitest/autorun'
