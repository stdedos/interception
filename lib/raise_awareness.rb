require 'thread'

module RaiseAwareness

  class << self
    attr_accessor :mutex, :listeners
  end

  self.mutex = Mutex.new
  self.listeners = []

  def self.listen(for_block=nil, &listen_block)
    raise "no block given" unless listen_block || for_block
    mutex.synchronize{
      listeners << listen_block || for_block
      start
    }

    if listen_block && for_block
      begin
        for_block.call
      ensure
        unlisten listen_block
      end
    end
  end

  def self.unlisten(listen_block)
    mutex.synchronize{
      listeners.delete listen_block
      stop if listeners.empty?
    }
  end

  def self.rescue(e, binding)
    listeners.each do |l|
      l.call(e, binding)
    end
  end

  if defined? Rubinius
    def self.start
      class << Rubinius
        alias raise_with_no_awareness raise_exception

        def raise_exception(exc)
          bt = Rubinius::VM.backtrace(1, true).drop_while do |x|
            x.variables.method.file.to_s.start_with?("kernel/")
          end.first
          b = Binding.setup(bt.variables, bt.variables.method, bt.constant_scope, bt.variables.self, bt)

          RaiseAwareness.rescue(exc, b)
          raise_with_no_awareness(exc)
        end
      end
    end

    def self.stop
      class << Rubinius
        alias raise_exception raise_with_no_awareness
      end
    end
  elsif defined?(JRuby)
    $CLASSPATH << File.expand_path('../../ext/', __FILE__)
    java_import org.pryrepl.RaiseAwarenessEventHook

    def self.start
      JRuby.runtime.add_event_hook(hook)
    end

    def self.stop
      JRuby.runtime.remove_event_hook(hook)
    end

    def self.hook
      @hook ||= RaiseAwarenessEventHook.new(proc do |e, b|
        self.rescue(e, b)
      end)
    end

  else
    require File.expand_path('../../ext/raise_awareness.so', __FILE__)
  end
end
