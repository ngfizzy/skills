#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates the evaluation files under evals/.
#
# These checks are structural and offline. They confirm that every skill has an
# evaluation, that it discriminates in both directions, that its declared
# dependencies are real, and that its behavioral cases are stated in checkable
# terms. They do not run an agent, so they cannot tell you whether a skill
# actually triggers or behaves correctly. Executing the behavioral cases needs
# an agent; see evals/README.md.

require "yaml"

# Defaults to this repository. An explicit root keeps the tests off the real tree.
ROOT = ARGV[0] ? File.expand_path(ARGV[0]) : File.expand_path("..", __dir__)
SKILLS_DIR = File.join(ROOT, "skills")
EVALS_DIR = File.join(ROOT, "evals")

MINIMUM_TRIGGERS_PER_DIRECTION = 2

def skill_names
  Dir.children(SKILLS_DIR).select { |entry| File.file?(File.join(SKILLS_DIR, entry, "SKILL.md")) }.sort
end

def non_empty_string?(value)
  value.is_a?(String) && !value.strip.empty?
end

def string_list(value)
  return [] unless value.is_a?(Array)

  value
end

def check_trigger_cases(errors, label, cases, known_skills)
  unless cases.is_a?(Array) && cases.length >= MINIMUM_TRIGGERS_PER_DIRECTION
    errors << "#{label} must list at least #{MINIMUM_TRIGGERS_PER_DIRECTION} cases"
    return
  end

  cases.each_with_index do |trigger_case, index|
    position = "#{label}[#{index}]"
    unless trigger_case.is_a?(Hash)
      errors << "#{position} must be a mapping"
      next
    end

    errors << "#{position} needs a non-empty situation" unless non_empty_string?(trigger_case["situation"])
    errors << "#{position} needs a non-empty because" unless non_empty_string?(trigger_case["because"])

    instead = trigger_case["instead"]
    next if instead.nil?

    unless known_skills.include?(instead)
      errors << "#{position} redirects to #{instead.inspect}, which is not a skill in this repository"
    end
  end
end

def check_behaviors(errors, behaviors)
  unless behaviors.is_a?(Array) && !behaviors.empty?
    errors << "behaviors must list at least one case"
    return
  end

  behaviors.each_with_index do |behavior, index|
    position = "behaviors[#{index}]"
    unless behavior.is_a?(Hash)
      errors << "#{position} must be a mapping"
      next
    end

    errors << "#{position} needs a non-empty name" unless non_empty_string?(behavior["name"])
    errors << "#{position} needs a non-empty given" unless non_empty_string?(behavior["given"])

    must = string_list(behavior["must"])
    errors << "#{position} needs at least one must assertion" if must.empty?

    (must + string_list(behavior["must_not"])).each_with_index do |assertion, assertion_index|
      unless non_empty_string?(assertion)
        errors << "#{position} assertion #{assertion_index} must be a non-empty string"
      end
    end
  end
end

# `requires` must stay in step with the skill text in both directions: every
# declared dependency has to be mentioned, and every sibling skill mentioned in
# the body has to be declared. A reference to a skill outside this repository
# cannot be detected here and is caught by review instead.
def check_requires(errors, skill_name, requires, known_skills)
  requires.each do |required|
    unless known_skills.include?(required)
      errors << "requires #{required.inspect}, which is not a skill in this repository"
      next
    end

    errors << "requires #{required.inspect} but must not require itself" if required == skill_name
  end

  body = File.read(File.join(SKILLS_DIR, skill_name, "SKILL.md"), encoding: "UTF-8")
  mentioned = body.scan(/`([a-z0-9-]+)`/).flatten.uniq & (known_skills - [skill_name])

  (requires - mentioned).each do |declared|
    errors << "requires #{declared.inspect} but #{skill_name}/SKILL.md never mentions it"
  end
  (mentioned - requires).each do |used|
    errors << "#{skill_name}/SKILL.md mentions #{used.inspect} but the evaluation does not require it"
  end
end

known_skills = skill_names
abort("No skills found under #{SKILLS_DIR}") if known_skills.empty?

eval_files = Dir.glob(File.join(EVALS_DIR, "*.yaml")).sort
evaluated = eval_files.map { |path| File.basename(path, ".yaml") }

failures = []
behavior_count = 0

(known_skills - evaluated).each { |skill| failures << "#{skill}: no evaluation file at evals/#{skill}.yaml" }
(evaluated - known_skills).each { |name| failures << "evals/#{name}.yaml does not correspond to any skill" }

eval_files.each do |path|
  name = File.basename(path, ".yaml")
  errors = []

  begin
    document = YAML.safe_load(File.read(path, encoding: "UTF-8"), aliases: false)
  rescue Psych::SyntaxError => error
    failures << "evals/#{name}.yaml has invalid YAML: #{error.message.lines.first.strip}"
    next
  end

  unless document.is_a?(Hash)
    failures << "evals/#{name}.yaml must be a mapping"
    next
  end

  errors << "skill must be #{name.inspect}, got #{document['skill'].inspect}" unless document["skill"] == name

  triggers = document["triggers"]
  if triggers.is_a?(Hash)
    check_trigger_cases(errors, "triggers.should_load", triggers["should_load"], known_skills)
    check_trigger_cases(errors, "triggers.should_not_load", triggers["should_not_load"], known_skills)
  else
    errors << "triggers must be a mapping with should_load and should_not_load"
  end

  check_behaviors(errors, document["behaviors"])
  behavior_count += document["behaviors"].length if document["behaviors"].is_a?(Array)

  if known_skills.include?(name)
    check_requires(errors, name, string_list(document["requires"]), known_skills)
  end

  errors.each { |error| failures << "evals/#{name}.yaml: #{error}" }
end

unless failures.empty?
  warn failures.join("\n")
  exit 1
end

puts "Evaluations are well formed: #{evaluated.length} skill(s), #{behavior_count} behavioral case(s)."
puts "Structural checks only. Run the behavioral cases with an agent; see evals/README.md."
