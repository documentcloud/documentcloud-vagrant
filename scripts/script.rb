# A small class that can run multiple scripts in parallel.  
# It logs the output of scripts to a file with the same 
# name as the script with extension .output
# If the script exits with a non-zero status, the 
# .output file is moved to a .fail file, 
# allowing the step to be re-ran.
#
#  Using the .output files' mtime, the runner 
#  can prevent re-running scripts that are not 
#  needed
#
#  Example Usage:
#    Script['test'].run_daily, :as_root=>true
#  For more examples, see the runner script


require 'thread'

class Script

  @@directory = '/vagrant/scripts'
  @@user = 'ubuntu'
  @@threads = []
  @@semaphore = Mutex.new
  def initialize( name )
    @name = name
    @file = "#{@@directory}/#{name}"
    @status = "#{@@directory}/#{name}.output"
  end

  def log( str )
    File.open(@status,'a') do | status |
      status.write str + "\n"
    end
  end

  def has_ran?
    File.exists?( @status )
  end

  def last_run
    has_ran? ? File.mtime( @status ) : Time.at(0)
  end

  def run(opts)
    t=Thread.new do 
      File.unlink( @status ) if has_ran?
      STDOUT.sync = true
      shell = opts[:shell] ? opts[:shell] : '/bin/bash'
      args = opts[:args] ? opts[:args].map{|k,v| "--#{k}=#{v}" }.join(' ') : ''
      cmd = opts[:as_root] ? "#{shell} #{@file} #{args} 2>&1" : "su #{@@user} -s #{shell} #{@file} -- #{args} 2>&1"
      log cmd
      Script.output "Running: #{@name} #{opts[:msg]}"
      IO.popen( cmd ) do | stdout |
        while line = stdout.gets
          log line
        end
      end
      if 0 != $?.exitstatus
        Script.output do
          STDERR.puts "ERROR: #{@name} exited with status #{$?.exitstatus}"
        end
        File.rename @status, "#{@@directory}/#{@name}.fail"
      end
      @@semaphore.synchronize { @@threads.delete( Thread.current ) }
    end
    @@semaphore.synchronize { @@threads << t }
    if opts[:wait]
      t.join
    end
    t
  end

  def run_if( condition, opts )
    if condition
      run( opts )
    else
      Script.output( "Skipping: #{@name} #{opts[:skip_msg]}" )
    end
    
  end

  class << self
    @@output_mutex = Mutex.new

    def user=(u)
      @@user=u
    end
    def directory=(d)
      @@directory=d
    end

    def output( msg='' )
      @@output_mutex.synchronize do
        puts msg unless msg.empty?
        yield if block_given?
      end
    end

    def []( script_name )
      script = Script.new( script_name )
      return Script::ConditionalRunner.new( script )
    end

    def wait_for_completion( thread=nil )
      waiting = thread ? [ thread ] : @@threads
      waiting.each do | t | 
        t.join
      end
    end

  end


  class ConditionalRunner
    DAY = 60 * 60 * 24
    attr_reader :script

    def initialize( script )
      @script = script
    end

    def run( opts={} )
      return @script.run(opts)
    end

    def run_once( opts={} )
      @script.run_if( ! @script.has_ran? , opts )
    end

    def run_daily(  opts={} )
      @script.run_if( @script.last_run < Time.now-DAY, opts )
    end

    def run_weekly( opts={} )
      @script.run_if( @script.last_run < Time.now-(DAY*7), opts )
    end
  end
end
