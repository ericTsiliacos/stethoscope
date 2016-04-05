task :default => [:tests]

desc 'run acceptance tests'
task :tests do
  pid = spawn(".stack-work/dist/x86_64-osx/Cabal-1.22.5.0/build/stethoscope-exe/stethoscope-exe")
  Process.detach(pid)

  puts `rspec`

  Process.kill('TERM', pid)
end
