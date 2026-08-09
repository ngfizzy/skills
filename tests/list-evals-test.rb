#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
LISTER = File.join(ROOT, "scripts", "list-evals.rb")

def assert(condition, message)
  raise message unless condition
end

def run_lister(root, skill: nil)
  arguments = ["--root", root]
  arguments += ["--skill", skill] if skill
  stdout, stderr, status = Open3.capture3("ruby", LISTER, *arguments, chdir: ROOT)
  [status.success?, "#{stdout}#{stderr}"]
end

def write_skill_with_eval(root, name, document)
  skill_dir = File.join(root, "skills", name)
  FileUtils.mkdir_p(skill_dir)
  File.write(File.join(skill_dir, "SKILL.md"), "---\nname: #{name}\ndescription: \"Test.\"\n---\n")
  File.write(File.join(skill_dir, "eval.yaml"), YAML.dump(document))
end

def sample(skill, instead: nil)
  should_not = { "situation" => "Neighbour case for #{skill}.", "because" => "Out of scope." }
  should_not["instead"] = instead if instead
  {
    "skill" => skill,
    "triggers" => {
      "should_load" => [{ "situation" => "Core case for #{skill}.", "because" => "Core reason." }],
      "should_not_load" => [should_not]
    },
    "behaviors" => [
      { "name" => "Named case", "given" => "Scenario text.", "must" => ["Required property."], "must_not" => ["Forbidden property."] }
    ]
  }
end

Dir.mktmpdir("skills-list-evals-test") do |temporary_root|
  root = File.join(temporary_root, "repo")
  FileUtils.mkdir_p(File.join(root, "skills"))
  write_skill_with_eval(root, "alpha", sample("alpha", instead: "beta"))
  write_skill_with_eval(root, "beta", sample("beta"))

  passed, output = run_lister(root)
  assert(passed, "listing failed:\n#{output}")

  # Every case reaches the output; a silently dropped case would make the
  # checklist claim coverage it does not have.
  assert(output.include?("Core case for alpha."), "a should_load situation was missing")
  assert(output.include?("Neighbour case for alpha."), "a should_not_load situation was missing")
  assert(output.include?("Scenario text."), "a behavior scenario was missing")
  assert(output.include?("Required property."), "a must assertion was missing")
  assert(output.include?("Forbidden property."), "a must_not assertion was missing")

  # Direction and redirect must be visible, or the checklist cannot be judged.
  assert(output.include?("must load alpha"), "the positive direction was not stated")
  assert(output.include?("must NOT load alpha"), "the negative direction was not stated")
  assert(output.include?("must load beta instead"), "the redirect target was not stated")
  assert(output.include?("must load nothing"), "a negative case without a redirect was not stated")

  assert(output.include?("2 skill(s), 4 trigger case(s), 2 behavior case(s)."), "the totals were wrong:\n#{output}")

  # Filtering narrows to one skill.
  filtered_passed, filtered = run_lister(root, skill: "alpha")
  assert(filtered_passed, "filtered listing failed:\n#{filtered}")
  assert(filtered.include?("ALPHA"), "the requested skill was missing")
  assert(!filtered.include?("Core case for beta."), "filtering did not exclude the other skill")
  assert(filtered.include?("1 skill(s),"), "the filtered totals were wrong")

  # An unknown skill fails rather than printing an empty checklist.
  unknown_passed, unknown_output = run_lister(root, skill: "nonexistent")
  assert(!unknown_passed, "an unknown skill was accepted")
  assert(unknown_output.include?("No evaluation for skill"), "the unknown skill was not explained")
end

puts "Evaluation listing tests passed."
