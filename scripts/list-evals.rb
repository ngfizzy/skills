#!/usr/bin/env ruby
# frozen_string_literal: true

# Prints evaluation cases as a checklist for a manual pass.
#
# The behavioral half of an evaluation needs an agent and cannot be scored
# offline, so working through it means reading each case, running it in a fresh
# session, and judging the result. This turns the YAML into something you can
# work down without opening the files.
#
# Usage:
#   list-evals.rb [--root DIR] [--skill NAME]

require "yaml"

options = { root: File.expand_path("..", __dir__), skill: nil }
arguments = ARGV.dup
until arguments.empty?
  flag = arguments.shift
  case flag
  when "--root" then options[:root] = File.expand_path(arguments.shift.to_s)
  when "--skill" then options[:skill] = arguments.shift
  else
    warn "Unknown argument: #{flag}"
    exit 2
  end
end

skills_dir = File.join(options[:root], "skills")

skills = Dir.children(skills_dir)
            .select { |entry| File.file?(File.join(skills_dir, entry, "eval.yaml")) }
            .sort
skills &= [options[:skill]] if options[:skill]

if skills.empty?
  warn(options[:skill] ? "No evaluation for skill: #{options[:skill]}" : "No evaluations found under #{skills_dir}")
  exit 1
end

def wrap(text, width, indent)
  words = text.to_s.split(/\s+/)
  lines = [+""]
  words.each do |word|
    if lines.last.empty?
      lines.last << word
    elsif lines.last.length + 1 + word.length <= width
      lines.last << " " << word
    else
      lines << +word
    end
  end
  lines.join("\n#{' ' * indent}")
end

WIDTH = 74

puts "Manual evaluation checklist"
puts
puts "Use a fresh session for every case. A skill loaded earlier in a session"
puts "changes what loads later, which is what a trigger case is measuring."
puts

trigger_total = 0
behavior_total = 0

skills.each do |skill|
  document = YAML.safe_load(File.read(File.join(skills_dir, skill, "eval.yaml"), encoding: "UTF-8"), aliases: false)
  triggers = document["triggers"] || {}
  behaviors = document["behaviors"] || []

  load_cases = triggers["should_load"] || []
  skip_cases = triggers["should_not_load"] || []

  puts "=" * WIDTH
  puts skill.upcase
  puts "=" * WIDTH
  puts

  unless load_cases.empty? && skip_cases.empty?
    puts "TRIGGERS — paste the line, then check which skill loaded."
    puts

    load_cases.each_with_index do |trigger_case, index|
      trigger_total += 1
      puts "  [ ] T#{index + 1}  must load #{skill}"
      puts "      say:    #{wrap(trigger_case['situation'], WIDTH - 14, 14)}"
      puts "      reason: #{wrap(trigger_case['because'], WIDTH - 14, 14)}"
      puts
    end

    skip_cases.each_with_index do |trigger_case, index|
      trigger_total += 1
      expected = trigger_case["instead"] ? "must load #{trigger_case['instead']} instead" : "must load nothing"
      puts "  [ ] T#{load_cases.length + index + 1}  must NOT load #{skill} — #{expected}"
      puts "      say:    #{wrap(trigger_case['situation'], WIDTH - 14, 14)}"
      puts "      reason: #{wrap(trigger_case['because'], WIDTH - 14, 14)}"
      puts
    end
  end

  unless behaviors.empty?
    puts "BEHAVIORS — set up the scenario, then judge the response."
    puts

    behaviors.each_with_index do |behavior, index|
      behavior_total += 1
      puts "  B#{index + 1}  #{behavior['name']}"
      puts "      given:  #{wrap(behavior['given'], WIDTH - 14, 14)}"
      Array(behavior["must"]).each do |assertion|
        puts "      [ ] does:     #{wrap(assertion, WIDTH - 20, 20)}"
      end
      Array(behavior["must_not"]).each do |assertion|
        puts "      [ ] does not: #{wrap(assertion, WIDTH - 20, 20)}"
      end
      puts
    end
  end
end

puts "-" * WIDTH
puts "#{skills.length} skill(s), #{trigger_total} trigger case(s), #{behavior_total} behavior case(s)."
puts "A behavior case passes only when every line under it holds."
