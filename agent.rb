require './watched_log.rb'

run([
    ['rpm_test_app/log/newrelic_agent.log', RUBY_ERRORS],
    ['rpm_site/java_collector/log/collector.8081.log', JAVA_ERRORS],
    ['rpm_site/beacon/log/server.9000.log', JAVA_ERRORS],])
