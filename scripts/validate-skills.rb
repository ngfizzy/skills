#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

def validate_skill(skill_dir)
  skill_file = File.join(skill_dir, "SKILL.md")
  raise "missing #{skill_file}" unless File.file?(skill_file)

  lines = File.readlines(skill_file, encoding: "UTF-8")
  raise "#{skill_file} must start with ---" unless lines.first&.strip == "---"

  closing_index = lines.each_index.find { |index| index.positive? && lines[index].strip == "---" }
  raise "#{skill_file} is missing the closing frontmatter delimiter" unless closing_index

  metadata = YAML.safe_load(lines[1...closing_index].join, [], [], false)
  raise "#{skill_file} frontmatter must be a mapping" unless metadata.is_a?(Hash)

  expected_name = File.basename(skill_dir)
  actual_name = metadata["name"]
  raise "#{skill_file} name must be #{expected_name.inspect}, got #{actual_name.inspect}" unless actual_name == expected_name

  description = metadata["description"]
  raise "#{skill_file} description must be a non-empty string" unless description.is_a?(String) && !description.strip.empty?
rescue Psych::SyntaxError => error
  raise "#{skill_file} has invalid YAML frontmatter: #{error.message.lines.first.strip}"
end

if ARGV.empty?
  warn "Usage: #{$PROGRAM_NAME} <skill-directory> [<skill-directory> ...]"
  exit 2
end

errors = ARGV.map do |skill_dir|
  validate_skill(skill_dir)
  nil
rescue StandardError => error
  error.message
end.compact

unless errors.empty?
  warn errors.join("\n")
  exit 1
end
