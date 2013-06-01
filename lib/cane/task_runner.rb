# Provides a SimpleTaskRunner or Parallel task runner based on configuration
module Cane
  def task_runner(opts)
    if opts[:parallel]
      Parallel
    else
      SimpleTaskRunner
    end
  end
  module_function :task_runner

  # Mirrors the Parallel gem's interface but does not provide any parallelism.
  # This is faster for smaller tasks since it doesn't incur any overhead for
  # creating new processes and communicating between them.
  class SimpleTaskRunner
    def self.map(enumerable, &block)
      enumerable.map(&block)
    end
  end
end
