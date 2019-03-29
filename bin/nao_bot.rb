require 'slack-ruby-client'

require_relative '../lib/config_manager'
require_relative '../lib/text_manager'

config = ConfigManager.instance
text = TextManager.instance

Slack.configure { |config| config.token = ConfigManager.instance.slack_token }
client = Slack::RealTime::Client.new

config.channels = {
  general: client.web_client.channels_info(channel: '#general')['channel']['id'],
  random:  client.web_client.channels_info(channel: '#random')['channel']['id'],
}.freeze

client.on :hello do
  NAO_ID = client.self.id
  puts <<-EOS
=====================================================
Successfully connected!
Bot name    : #{client.self.name}
Bot user_id : #{client.self.id}
Client Team : #{client.team.name}
Domain      : https://#{client.team.domain}.slack.com
=====================================================
  EOS
  client.message channel: config.channel(:random), text: text.hello
end

client.on :message do |message|
  p message
  EM.defer do
    begin
      # TODO
      unless message.user == client.self.id
        case message.text
          when /<@#{NAO_ID}> マスター取.込/
            client.message channel: message.channel, text: "<@#{message.user}> 取り込みます！"
            Dir.chdir(config.game_server_path) do
              #system("git stash; git checkout master; git pull origin master; bin/rake db:migrate")
              #system("bin/rake master:update > tmp/import.log")
              importing_error = ''
              File.foreach('tmp/import.log') do |line|
                importing_error.concat(line.gsub(/\e\[[0-9]+m/, '')) if line.match(/\p{Hiragana}|\p{Katakana}|\p{Han}/)
              end
              unless importing_error.blank?
                client.web_client.files_upload(
                  channels: config.channel(:random),
                  title: 'マスター取り込みエラー',
                  filename: 'error.txt',
                  content: importing_error,
                  initial_comment: '<!here>'
                )
              else
                client.message channel: message.channel, text: "<@#{message.user}> エラーなかったで！"
              end
            end
          when /<@#{NAO_ID}> ステージング更新/
            client.message channel: message.channel, text: "<@#{message.user}> やるッスやるッスー！　お手伝いするッスー！"
            raise
          when /<@#{NAO_ID}>/
            client.message channel: message.channel, text: "<@#{message.user}> わかんないッスー!!!"
          end
        end

    rescue => e
      raise e
    end
  end
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!
