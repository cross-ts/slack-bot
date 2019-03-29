require 'singleton'
require 'yaml'

class ConfigManager
  include Singleton

  def initialize
    @config = YAML.load_file(File.dirname(File.expand_path(__FILE__)) + "/../config/config.yml")
  end

  def slack_token
    @config["slack_token"]
  end

  def game_server_path
    @config["game_server_path"]
  end

  def channels=(hash)
    @channels ||= hash
  end

  def channel(channel_name)
    @channels[channel_name]
  end
end
