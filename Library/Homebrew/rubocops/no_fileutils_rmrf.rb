# typed: true
# frozen_string_literal: true

module RuboCop
  module Cop
    module Homebrew
      # This cop checks for the use of `FileUtils.rm_f`, `FileUtils.rm_rf`, or `{FileUtils,Pathname}.rmtree`
      # and recommends the safer versions.
      class NoFileutilsRmrf < Base
        extend AutoCorrector

        MSG = "Use `FileUtils.rm` or `FileUtils.rm_r` instead of `FileUtils.rm_rf`, `FileUtils.rm_f`, " \
              "or `{FileUtils,Pathname}.rmtree`."

        def_node_matcher :fileutils_rm_r_f?, <<~PATTERN
          (send (const {nil? cbase} :FileUtils) {:rm_rf :rm_f :rmtree} ...)
        PATTERN

        def_node_matcher :pathname_rmtree?, <<~PATTERN
          (send (const {nil? cbase} :Pathname) :rmtree ...)
        PATTERN

        def on_send(node)
          return if neither_rm_rf_nor_rmtree?(node)

          add_offense(node) do |corrector|
            new_method = if node.method?(:rm_rf) || node.method?(:rmtree)
              "rm_r"
            else
              "rm"
            end

            corrector.replace(node.loc.expression, "FileUtils.#{new_method}(#{node.arguments.first.source})")
          end
        end

        def neither_rm_rf_nor_rmtree?(node)
          !fileutils_rm_r_f?(node) && !pathname_rmtree?(node)
        end
      end
    end
  end
end
