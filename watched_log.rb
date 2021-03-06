require 'terminal-notifier'
require 'file-tail'

$newrelic_root = ARGV[0] || Dir.pwd

RUBY_ERRORS = [
  /(ERROR \: .*)/,
]

JAVA_ERRORS = [
  /( FATAL .*)/,
  /(.*Exception\:.*)/,
  /(.*Exception$)/,
]

def tail_file(path, patterns)
  Thread.new do 
    full_path = File.absolute_path(File.join($newrelic_root, path))
    File.open(full_path) do |log|
      log.extend(File::Tail)
      log.interval = 10
      log.backward(10)

      log.tail do |line|
        match = patterns.map { |r| r.match(line) }.compact.first
        if !match.nil?
          TerminalNotifier.notify(normalize_error(match[0]),
                                  :title => path,
                                  :open => "file://#{full_path}") 
        end
      end
    end
  end
end

def normalize_error(original)
  original.gsub(/[\[\]\(\)]/, '_')
end

def run(logs_to_watch)
  threads = []

  logs_to_watch.each do |log_pair|
    threads << tail_file(log_pair[0], log_pair[1])
  end

  threads.each { |t| t.join }
end
