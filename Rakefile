task :default => [:tests]

desc 'run acceptance tests'
task :tests => [:compile] do
  status = system 'stack test'
  raise "Backend tests failed" unless status

  status = system 'stack build'
  raise 'failed to compile backend' unless status

  pid = spawn("PORT=8080 stack exec stethoscope-exe",
              :out => 'spec/logs/server.out',
              :err => "spec/logs/server.err")
  Process.detach(pid)

  puts `rspec`

  Process.kill('TERM', pid)
end

desc 'run tests on ci'
task :ci => [:compile] do
  status = system 'stack --no-terminal --skip-ghc-check test'
  raise "Backend tests failed" unless status

  status = system 'stack --no-terminal --skip-ghc-check build'
  raise 'failed to compile backend' unless status

  spawn("PORT=8080 stack --no-terminal --skip-ghc-check exec stethoscope-exe",
        :out => 'spec/logs/server.out',
        :err => "spec/logs/server.err")
  
  puts `bundle exec rspec`
end

desc 'compile frontend'
task :compile do
  Dir.chdir 'frontend' do
    puts 'compiling frontend...'
    status = system 'LANG=C.UTF-8 elm make Main.elm --yes --output=../public/index.html'
    raise "Failed to compile frontend" unless status
  end
end

desc 'run app'
task :run => [:compile] do
  puts 'running app...'
  system 'stack build && PORT=8080 stack exec stethoscope-exe'
end
