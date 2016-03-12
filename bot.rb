require 'slack-ruby-client'
require 'figaro'

def figaro_init
  Figaro.application = Figaro::Application.new(environment: 'production', path: 'config/application.yml')
  Figaro.load
  Figaro.require_keys('SLACK_API_TOKEN')
end

def slack_init
  Slack.configure { |config| config.token = ENV['SLACK_API_TOKEN'] }
end


figaro_init
slack_init

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
end

client.on :message do |data|
  puts data

  if matchdata = /(^\.test)(.*)/.match(data['text'])
    client.message(channel: data['channel'], text: "Hello World")
  end
end

client.start!
