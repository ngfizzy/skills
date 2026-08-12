#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"

ROOT = File.expand_path("..", __dir__)

TARGET_VARIABLES = {
  "CODEX_SKILLS_DIR" => "codex",
  "COPILOT_SKILLS_DIR" => "copilot",
  "CLAUDE_SKILLS_DIR" => "claude",
  "ANTIGRAVITY_SKILLS_DIR" => "antigravity"
}.freeze

REPOSITORY_SKILLS = Dir.children(File.join(ROOT, "skills")).select do |entry|
  File.file?(File.join(ROOT, "skills", entry, "SKILL.md"))
end.sort.freeze

def assert(condition, message)
  raise message unless condition
end

def run_make(environment, *arguments)
  stdout, stderr, status = Open3.capture3(environment, "make", *arguments, chdir: ROOT)
  [status.success?, "#{stdout}#{stderr}"]
end

def test_environment(root, copy_command: nil)
  environment = TARGET_VARIABLES.to_h { |variable, directory| [variable, File.join(root, directory)] }
  environment["COPY"] = copy_command if copy_command
  environment
end

# Unrelated entries stand in for built-in or third-party skills that the
# installer must never touch.
def seed_target(target)
  FileUtils.mkdir_p(File.join(target, "unrelated"))
  File.write(File.join(target, "unrelated", "keep.txt"), "keep")
end

def seed_installed_skill(target, skill)
  FileUtils.mkdir_p(File.join(target, skill))
  File.write(File.join(target, skill, "SKILL.md"), "---\nname: #{skill}\ndescription: \"Previously installed.\"\n---\n")
  File.write(File.join(target, skill, "marker.txt"), "previous")
end

Dir.mktmpdir("skills-install-test") do |temporary_root|
  assert(!REPOSITORY_SKILLS.empty?, "no skills found to install")
  sample_skill = REPOSITORY_SKILLS.first
  other_skills = REPOSITORY_SKILLS - [sample_skill]

  # A full install writes every skill to every target and preserves unrelated entries.
  install_environment = test_environment(File.join(temporary_root, "install"))
  install_targets = install_environment.values_at(*TARGET_VARIABLES.keys)
  install_targets.each { |target| seed_target(target) }
  missing_target = install_environment.fetch("ANTIGRAVITY_SKILLS_DIR")
  FileUtils.rm_rf(missing_target)
  assert(!File.exist?(missing_target), "missing-target fixture was not removed")

  installed, output = run_make(install_environment, "install")
  assert(installed, "install failed:\n#{output}")
  assert(File.directory?(missing_target), "install did not create the missing target directory")
  install_targets.each do |target|
    REPOSITORY_SKILLS.each do |skill|
      assert(File.file?(File.join(target, skill, "SKILL.md")), "#{skill} was not installed into #{target}")
    end
    next if target == missing_target

    assert(File.file?(File.join(target, "unrelated", "keep.txt")), "unrelated entries were not preserved")
  end

  # Evaluations sit beside their skill so they travel with it, but they are
  # development material and must never reach an install root: their assertions
  # are phrased as instructions an agent could act on.
  assert(
    REPOSITORY_SKILLS.any? { |skill| File.file?(File.join(ROOT, "skills", skill, "eval.yaml")) },
    "no skill has an eval.yaml, so this test cannot prove the installer strips it"
  )
  install_targets.each do |target|
    REPOSITORY_SKILLS.each do |skill|
      assert(!File.exist?(File.join(target, skill, "eval.yaml")), "#{skill} evaluation was installed into #{target}")
    end
  end

  # Reinstalling replaces the skill directory rather than merging into it, so
  # files removed upstream do not survive in an installed copy.
  install_targets.each { |target| File.write(File.join(target, sample_skill, "stale.txt"), "stale") }
  reinstalled, reinstall_output = run_make(install_environment, "install")
  assert(reinstalled, "reinstall failed:\n#{reinstall_output}")
  install_targets.each do |target|
    assert(!File.exist?(File.join(target, sample_skill, "stale.txt")), "reinstall merged into the existing skill directory")
  end

  # A failed copy must leave the previously installed skill and unrelated entries intact.
  failure_environment = test_environment(File.join(temporary_root, "failure"), copy_command: "false")
  failure_targets = failure_environment.values_at(*TARGET_VARIABLES.keys)
  failure_targets.each do |target|
    seed_target(target)
    seed_installed_skill(target, sample_skill)
  end

  failed, = run_make(failure_environment, "install")
  assert(!failed, "a forced copy failure unexpectedly succeeded")
  failure_targets.each do |target|
    assert(File.file?(File.join(target, sample_skill, "marker.txt")), "a failed install destroyed the installed skill")
    assert(File.file?(File.join(target, "unrelated", "keep.txt")), "a failed install destroyed unrelated entries")
    assert(Dir.glob(File.join(target, ".skills-staging-*")).empty?, "a failed install left staging directories behind")
  end

  # Selecting one skill installs only that skill.
  single_environment = test_environment(File.join(temporary_root, "single"))
  single_targets = single_environment.values_at(*TARGET_VARIABLES.keys)
  single_targets.each { |target| seed_target(target) }

  single_installed, single_output = run_make(single_environment, "install", "SKILL=#{sample_skill}")
  assert(single_installed, "single-skill install failed:\n#{single_output}")
  single_targets.each do |target|
    assert(File.file?(File.join(target, sample_skill, "SKILL.md")), "#{sample_skill} was not installed")
    other_skills.each do |skill|
      assert(!File.exist?(File.join(target, skill)), "#{skill} was installed despite SKILL=#{sample_skill}")
    end
  end

  # Uninstall removes only the selected skill.
  uninstall_environment = test_environment(File.join(temporary_root, "uninstall"))
  uninstall_targets = uninstall_environment.values_at(*TARGET_VARIABLES.keys)
  uninstall_targets.each { |target| seed_target(target) }
  run_make(uninstall_environment, "install")

  uninstalled, uninstall_output = run_make(uninstall_environment, "uninstall", "SKILL=#{sample_skill}")
  assert(uninstalled, "uninstall failed:\n#{uninstall_output}")
  uninstall_targets.each do |target|
    assert(!File.exist?(File.join(target, sample_skill)), "#{sample_skill} survived uninstall")
    other_skills.each do |skill|
      assert(File.file?(File.join(target, skill, "SKILL.md")), "uninstall removed the unrelated skill #{skill}")
    end
    assert(File.file?(File.join(target, "unrelated", "keep.txt")), "uninstall removed unrelated entries")
  end

  # Uninstall refuses a name that this repository does not own.
  refused, = run_make(uninstall_environment, "uninstall", "SKILL=not-a-real-skill")
  assert(!refused, "uninstall accepted a skill this repository does not own")
  assert(File.file?(File.join(uninstall_targets.first, "unrelated", "keep.txt")), "a refused uninstall touched the target")
end

puts "Installer tests passed."
