# encoding: utf-8

if RUBY_VERSION < '1.9.0'
  $KCODE = "u"
end

require 'irb/completion'
require 'irb/ext/save-history'
require 'rubygems'
require 'pp'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_PATH] = File::expand_path("~/.irb_history")
IRB.conf[:PROMPT_MODE] = :DEFAULT

autoload :Date, "date"
autoload :JSON, "json"
autoload :URI, "uri"
autoload :FileUtils, "fileutils"
autoload :YAML, "yaml"
autoload :SecureRandom, "securerandom"
autoload :Pathname, "pathname"
autoload :Tempfile, "tempfile"
autoload :Logger, "logger"
autoload :CSV, "csv"
autoload :ERB, "erb"
autoload :Base64, "base64"
autoload :CGI, "cgi"
