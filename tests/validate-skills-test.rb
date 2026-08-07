#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "tmpdir"

ROOT = File.expand_path("..", __dir__)
VALIDATOR = File.join(ROOT, "scripts", "validate-skills.rb")

def assert(condition, message)
  raise message unless condition
end

def run_validator(skill_dir)
  Open3.capture3("ruby", VALIDATOR, skill_dir, chdir: ROOT)
end

def write_skill(root, directory_name, frontmatter)
  skill_dir = File.join(root, directory_name)
  Dir.mkdir(skill_dir)
  File.write(File.join(skill_dir, "SKILL.md"), "---\n#{frontmatter}\n---\n")
  skill_dir
end

Dir.mktmpdir("skills-validator-test") do |temporary_root|
  valid_skill = write_skill(
    temporary_root,
    "valid-skill",
    %(name: valid-skill\ndescription: "A valid skill: with a colon.")
  )
  _, _, valid_status = run_validator(valid_skill)
  assert(valid_status.success?, "valid frontmatter was rejected")

  invalid_yaml_skill = write_skill(
    temporary_root,
    "invalid-yaml",
    "name: invalid-yaml\ndescription: Invalid YAML: contains an unquoted colon."
  )
  _, _, invalid_yaml_status = run_validator(invalid_yaml_skill)
  assert(!invalid_yaml_status.success?, "invalid YAML frontmatter was accepted")

  mismatched_name_skill = write_skill(
    temporary_root,
    "mismatched-name",
    %(name: another-name\ndescription: "Valid YAML with a mismatched name.")
  )
  _, _, mismatched_name_status = run_validator(mismatched_name_skill)
  assert(!mismatched_name_status.success?, "mismatched skill name was accepted")

  missing_description_skill = write_skill(temporary_root, "missing-description", "name: missing-description")
  _, _, missing_description_status = run_validator(missing_description_skill)
  assert(!missing_description_status.success?, "missing description was accepted")

  unterminated_skill = File.join(temporary_root, "unterminated")
  Dir.mkdir(unterminated_skill)
  File.write(File.join(unterminated_skill, "SKILL.md"), "---\nname: unterminated\ndescription: \"No closing delimiter.\"\n")
  _, _, unterminated_status = run_validator(unterminated_skill)
  assert(!unterminated_status.success?, "unterminated frontmatter was accepted")

  missing_file_skill = File.join(temporary_root, "missing-skill-file")
  Dir.mkdir(missing_file_skill)
  _, _, missing_file_status = run_validator(missing_file_skill)
  assert(!missing_file_status.success?, "a directory without SKILL.md was accepted")
end

puts "Skill frontmatter validation tests passed."
