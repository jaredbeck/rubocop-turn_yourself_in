require 'active_support/all'
require 'English'
require 'yaml'

module RuboCop
  module TurnYourselfIn
    class CLI
      E_USAGE = 1
      E_TODO_FILE_NOT_FOUND = 2
      E_TODO_FILE_PARSE_FAIL = 3
      E_GIT_ADD_FAIL = 4
      E_GIT_COMMIT_FAIL = 5
      E_RUBOCOP_AUTOCORRECT_FAIL = 6
      E_DIRTY_WORKING_COPY = 7
      TODO_FILENAME = '.rubocop_todo.yml'

      def initialize(argv)
        @options = {
          dry_run: false,
          prompt: true
        }
        args = argv.dup
        until args.empty?
          arg = args.shift
          if arg == '--dry-run'
            @options[:dry_run] = true
          elsif arg == '--no-prompt'
            @options[:prompt] = false
          else
            exit_with_usage
          end
        end
      end

      def run
        assert_clean_working_copy
        remove_comments
        loop do
          todos = parse_todos
          break if todos.empty?
          cop = todos.keys.first
          if @options[:prompt]
            print format('Auto-correct %s? (y/n/q) ', cop)
            choice = $stdin.gets.strip
          else
            choice = 'y'
          end
          if choice == 'y'
            write_todos(todos.except(cop))
            command('bin/rubocop -A', E_RUBOCOP_AUTOCORRECT_FAIL)
            commit(cop)
          elsif choice == 'q'
            break
          end
        end
      end

      private

      def exit_with_usage
        warn "Usage: turn_yourself_in --dry-run --no-prompt"
        exit E_USAGE
      end

      def command(cmd, exit_code)
        puts cmd
        return if @dry_run
        unless system(cmd)
          warn format('Command failed: exited with %s', $CHILD_STATUS.to_s)
          exit exit_code
        end
      end

      def commit(message)
        command('git add .', E_GIT_ADD_FAIL)
        command(format('git commit -m "Lint: TYI: %s"', message), E_GIT_COMMIT_FAIL)
      end

      def clean?
        return true if @dry_run
        `git status --porcelain`.strip.empty?
      end

      # First commit removes comments. We're not going to be able to keep them
      # because the parser discards them.
      def remove_comments
        todos = parse_todos
        write_todos(todos)
        commit('Remove comments') unless clean?
      end

      def parse_todos
        YAML.load(File.read(TODO_FILENAME))
      rescue Psych::SyntaxError => e
        warn e
        exit E_TODO_FILE_PARSE_FAIL
      rescue Errno::ENOENT => e
        warn format('File not found: %s: %s', TODO_FILENAME, e)
        exit E_TODO_FILE_NOT_FOUND
      end

      def assert_clean_working_copy
        return if clean?
        warn 'This script makes git commits but your working copy is not clean.'
        exit E_DIRTY_WORKING_COPY
      end

      def write_todos(todos)
        File.write(TODO_FILENAME, YAML.dump(todos))
      end
    end
  end
end
