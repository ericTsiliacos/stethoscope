task :default => [:tests]

desc 'run acceptance tests'
task :tests => [:compile] do
  status = system 'stack test'
  raise "Backend tests failed" unless status

  status = system 'stack build'
  raise 'failed to compile backend' unless status

  pid = spawn("PORT=8080 .stack-work/dist/x86_64-osx/Cabal-1.22.5.0/build/stethoscope-exe/stethoscope-exe",
              :out => 'spec/logs/server.out',
              :err => "spec/logs/server.err")
  Process.detach(pid)

  puts `rspec`

  Process.kill('TERM', pid)
end

desc 'compile frontend'
task :compile do
  Dir.chdir 'frontend' do
    puts 'compiling frontend...'
    status = system 'elm make Main.elm --output=../public/index.html'
    raise "Failed to compile frontend" unless status
  end
end

desc 'run app'
task :run => [:compile] do
  puts 'running app...'
  system 'stack build && PORT=8080 stack exec stethoscope-exe'
end
