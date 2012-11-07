require 'terminal-notifier'
require 'file-tail'

$newrelic_root = ARGV[0] || Dir.pwd

AGENT_ERRORS = [
  /(ERROR \: .*)/,
]

def tail_file(path, patterns)
  Thread.new do 
    File.open(File.join($newrelic_root, path)) do |log|
      log.extend(File::Tail)
      log.interval = 10
      log.backward(10)

      log.tail do |line|
        match = patterns.map { |r| r.match(line) }.compact.first
        if !match.nil?
          TerminalNotifier.notify(normalize_error(match[0]),
                                  :title => path,
                                  :open => "file://#{path}") 
        end
      end
    end
  end
end

def normalize_error(original)
  original.gsub(/[\[\]\(\)]/, '_')
end

threads = []

threads << tail_file('rpm_test_app/log/newrelic_agent.log', AGENT_ERRORS)

threads.each { |t| t.join }

