require 'slack-ruby-client'
require 'figaro'
require 'httparty'

class Server
  include HTTParty
  base_uri ENV['SERVER_URL']
end

def figaro_init
  Figaro.application = Figaro::Application.new(environment: 'production', path: 'config/application.yml')
  Figaro.load
  Figaro.require_keys('SLACK_API_TOKEN', 'SERVER_URL')
end

def slack_init
  Slack.configure { |config| config.token = ENV['SLACK_API_TOKEN'] }
end

def post_announcement(text)
  options = {
    body: {
      announcement: { # your resource
        text: text
      }
    }
  }

  puts Server.post('/announcements', options)
end


figaro_init
slack_init

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
end

client.on :message do |data|
  puts data

  if matchdata = /(^\.announce)(.*)/.match(data['text'])
    post_announcement(matchdata[2])
  end
end

client.start!
