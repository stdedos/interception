# frozen_string_literal: true

task :clean do
  sh 'rm -f ext/*.o ext/*.so ext/*.dylib'
  sh 'rm -f ext/org/pryrepl/*.class'
  sh 'rm -f ext/org/pryrepl/*.jar'
end

desc 'Compile C extension for CRuby'
task :compile_cruby do
  cd 'ext/' do
    sh 'ruby extconf.rb'
    sh 'make'
  end
end

desc 'Compile Java extension for JRuby'
task :compile_jruby do
  cd 'ext/' do
    sh 'find . -name "*.java" | xargs jrubyc --javac'
    sh 'find . -name "*.class" | xargs jar cf InterceptionEventHook.jar'
    sh 'cp InterceptionEventHook.jar ../lib/'
  end
end

desc 'Compile extension'
task :compile  => [:clean] do
  case defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'undefined'  # `undefined`: MRI < 1.9
  when 'jruby'
    Rake::Task[:compile_jruby].invoke
  when 'ruby', 'undefined', 'truffleruby'
    Rake::Task[:compile_cruby].invoke
  else
    raise "Unhandled engine: #{RUBY_ENGINE}"
  end
end

desc 'Run example'
task :example do
  sh 'ruby -I./lib/ ./examples/example.rb'
end

desc 'Run example 2'
task :example2 do
  sh 'ruby -I./lib/ ./examples/example2.rb'
end

desc 'Run tests'
task :test => [:compile] do
  sh 'rspec spec -r ./spec/spec_helpers.rb'
end

desc 'Compile and run tests'
task :default => [:test]
