# frozen_string_literal: true

require_relative "lib/rubocop/turn_yourself_in/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-turn_yourself_in"
  spec.version = Rubocop::TurnYourselfIn.gem_version
  spec.authors = ["Jared Beck"]
  spec.email = ["jared@jaredbeck.com"]
  spec.summary = "Fix RuboCop to-dos, with one git commit per cop"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6")
  spec.required_rubygems_version = Gem::Requirement.new(">= 3.0")
  spec.files = [
    "bin/turn_yourself_in",
    "lib/rubocop/turn_yourself_in.rb",
    "lib/rubocop/turn_yourself_in/cli.rb",
    "lib/rubocop/turn_yourself_in/version.rb"
  ]
  spec.executables << 'turn_yourself_in'
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency 'activesupport', '~> 6.1'
end
