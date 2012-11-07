require 'terminal-notifier'
require 'file-tail'

AGENT_ERRORS = [
  /(ERROR \: .*)/,
]

def tail_file(path, title, patterns)
  Thread.new do 
    File.open(path) do |log|
      log.extend(File::Tail)
      log.interval = 10
      log.backward(10)

      log.tail do |line|
        match = patterns.map { |r| r.match(line) }.compact.first
        if !match.nil?
          TerminalNotifier.notify(normalize_error(match[0]), :title => title) 
        end
      end
    end
  end
end

def normalize_error(original)
  original.gsub(/[\[\]\(\)]/, '_')
end

threads = []

threads << tail_file('/Users/jclark/source/newrelic/rpm_test_app/log/newrelic_agent.log', 
              'rpm_test_app',
              AGENT_ERRORS)

threads << tail_file('/Users/jclark/source/newrelic/rpm_test_app/log/newrelic_agent.log', 
              'RPM_TEST_APP AGAIN!',
              AGENT_ERRORS)

threads.each { |t| t.join }

