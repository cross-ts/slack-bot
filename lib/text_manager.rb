require 'singleton'
require 'yaml'

class TextManager
  include Singleton

  def initialize
    @text = YAML.load_file(File.dirname(File.expand_path(__FILE__)) + '/../text/nao.yml')
  end

  def hello
    @text["hello"]
  end

end
