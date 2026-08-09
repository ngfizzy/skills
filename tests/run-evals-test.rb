#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
RUNNER = File.join(ROOT, "scripts", "run-evals.rb")

def assert(condition, message)
  raise message unless condition
end

def run_runner(root)
  stdout, stderr, status = Open3.capture3("ruby", RUNNER, root, chdir: ROOT)
  [status.success?, "#{stdout}#{stderr}"]
end

def write_skill(root, name, body: "Guidance.")
  skill_dir = File.join(root, "skills", name)
  FileUtils.mkdir_p(skill_dir)
  File.write(File.join(skill_dir, "SKILL.md"), <<~MARKDOWN)
    ---
    name: #{name}
    description: "Test skill."
    ---

    #{body}
  MARKDOWN
end

# A complete, passing evaluation. Individual tests mutate one aspect of it so a
# failure can only come from the aspect under test.
def evaluation(skill:, requires: [], should_load: 2, should_not_load: 2, instead: nil, behaviors: 1, must: 1)
  document = {
    "skill" => skill,
    "requires" => requires,
    "triggers" => {
      "should_load" => Array.new(should_load) { |i| { "situation" => "Load case #{i}.", "because" => "Reason #{i}." } },
      "should_not_load" => Array.new(should_not_load) { |i| { "situation" => "Skip case #{i}.", "because" => "Reason #{i}." } }
    },
    "behaviors" => Array.new(behaviors) do |i|
      { "name" => "Case #{i}", "given" => "Scenario #{i}.", "must" => Array.new(must) { |j| "Assertion #{j}." } }
    end
  }
  document["triggers"]["should_not_load"][0]["instead"] = instead if instead
  document
end

# Evaluations live inside the skill directory so they travel with it.
def write_evaluation(root, name, document)
  File.write(File.join(root, "skills", name, "eval.yaml"), YAML.dump(document))
end

def build(temporary_root, name)
  root = File.join(temporary_root, name)
  FileUtils.mkdir_p(File.join(root, "skills"))
  yield root
  root
end

Dir.mktmpdir("skills-evals-test") do |temporary_root|
  # Baseline: a well-formed repository passes.
  baseline = build(temporary_root, "baseline") do |root|
    write_skill(root, "alpha")
    write_evaluation(root, "alpha", evaluation(skill: "alpha"))
  end
  passed, output = run_runner(baseline)
  assert(passed, "a well-formed repository was rejected:\n#{output}")
  assert(output.include?("1 skill(s)"), "runner did not report the skill count:\n#{output}")

  # A skill with no evaluation fails.
  missing = build(temporary_root, "missing") do |root|
    write_skill(root, "alpha")
    write_skill(root, "beta")
    write_evaluation(root, "alpha", evaluation(skill: "alpha"))
  end
  missing_passed, missing_output = run_runner(missing)
  assert(!missing_passed, "a skill without an evaluation was accepted")
  assert(missing_output.include?("beta"), "the failure did not name the unevaluated skill")

  # An evaluation copied into the wrong skill directory fails.
  misplaced = build(temporary_root, "misplaced") do |root|
    write_skill(root, "alpha")
    write_skill(root, "beta")
    write_evaluation(root, "alpha", evaluation(skill: "alpha"))
    write_evaluation(root, "beta", evaluation(skill: "alpha"))
  end
  misplaced_passed, misplaced_output = run_runner(misplaced)
  assert(!misplaced_passed, "an evaluation naming the wrong skill was accepted")
  assert(misplaced_output.include?("skill must be"), "the misplaced evaluation was not explained")

  # Triggers must discriminate in both directions.
  one_sided = build(temporary_root, "one-sided") do |root|
    write_skill(root, "alpha")
    write_evaluation(root, "alpha", evaluation(skill: "alpha", should_not_load: 1))
  end
  one_sided_passed, one_sided_output = run_runner(one_sided)
  assert(!one_sided_passed, "an evaluation with too few negative triggers was accepted")
  assert(one_sided_output.include?("should_not_load"), "the failure did not name the thin direction")

  # A redirect must name a real skill.
  bad_redirect = build(temporary_root, "bad-redirect") do |root|
    write_skill(root, "alpha")
    write_evaluation(root, "alpha", evaluation(skill: "alpha", instead: "nonexistent"))
  end
  bad_redirect_passed, = run_runner(bad_redirect)
  assert(!bad_redirect_passed, "a redirect to an unknown skill was accepted")

  # A declared dependency the skill never mentions fails.
  stale_requires = build(temporary_root, "stale-requires") do |root|
    write_skill(root, "alpha")
    write_skill(root, "beta")
    write_evaluation(root, "alpha", evaluation(skill: "alpha", requires: ["beta"]))
    write_evaluation(root, "beta", evaluation(skill: "beta"))
  end
  stale_passed, stale_output = run_runner(stale_requires)
  assert(!stale_passed, "a dependency the skill never mentions was accepted")
  assert(stale_output.include?("never mentions"), "the failure did not explain the stale dependency")

  # A mentioned sibling the evaluation does not declare fails.
  undeclared = build(temporary_root, "undeclared") do |root|
    write_skill(root, "alpha", body: "Use `beta` first.")
    write_skill(root, "beta")
    write_evaluation(root, "alpha", evaluation(skill: "alpha"))
    write_evaluation(root, "beta", evaluation(skill: "beta"))
  end
  undeclared_passed, undeclared_output = run_runner(undeclared)
  assert(!undeclared_passed, "an undeclared cross-reference was accepted")
  assert(undeclared_output.include?("does not require"), "the failure did not explain the undeclared reference")

  # A satisfied dependency in both directions passes.
  consistent = build(temporary_root, "consistent") do |root|
    write_skill(root, "alpha", body: "Use `beta` first.")
    write_skill(root, "beta")
    write_evaluation(root, "alpha", evaluation(skill: "alpha", requires: ["beta"]))
    write_evaluation(root, "beta", evaluation(skill: "beta"))
  end
  consistent_passed, consistent_output = run_runner(consistent)
  assert(consistent_passed, "a consistent cross-reference was rejected:\n#{consistent_output}")

  # Non-ASCII skill and evaluation text is read as UTF-8 regardless of locale.
  unicode = build(temporary_root, "unicode") do |root|
    write_skill(root, "alpha", body: "Avoid vague labels such as “handling” — use `beta` instead.")
    write_skill(root, "beta")
    write_evaluation(root, "alpha", evaluation(skill: "alpha", requires: ["beta"]))
    write_evaluation(root, "beta", evaluation(skill: "beta"))
  end
  unicode_passed, unicode_output = run_runner(unicode)
  assert(unicode_passed, "non-ASCII skill text was rejected:\n#{unicode_output}")

  # A behavioral case with no assertion fails.
  assertionless = build(temporary_root, "assertionless") do |root|
    write_skill(root, "alpha")
    write_evaluation(root, "alpha", evaluation(skill: "alpha", must: 0))
  end
  assertionless_passed, = run_runner(assertionless)
  assert(!assertionless_passed, "a behavioral case with no assertion was accepted")

  # Invalid YAML fails without raising.
  broken = build(temporary_root, "broken") do |root|
    write_skill(root, "alpha")
    File.write(File.join(root, "skills", "alpha", "eval.yaml"), "skill: alpha\ntriggers: [unclosed\n")
  end
  broken_passed, broken_output = run_runner(broken)
  assert(!broken_passed, "invalid YAML was accepted")
  assert(broken_output.include?("invalid YAML"), "invalid YAML was not reported clearly")
end

puts "Evaluation runner tests passed."
