IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_PATH] = File::expand_path("~/.irb_history")
IRB.conf[:PROMPT_MODE] = :DEFAULT
IRB.conf[:USE_AUTOCOMPLETE] = false

autoload :Base64, "base64"
autoload :CGI, "cgi"
autoload :CSV, "csv"
autoload :Date, "date"
autoload :ERB, "erb"
autoload :FileUtils, "fileutils"
autoload :JSON, "json"
autoload :Logger, "logger"
autoload :Pathname, "pathname"
autoload :SecureRandom, "securerandom"
autoload :Tempfile, "tempfile"
autoload :URI, "uri"
autoload :YAML, "yaml"

# for Object#to_json
require "json"

def encodeURIComponent(*args)
  CGI.escapeURIComponent(*args)
end

def encodeURIComponent(*args)
  CGI.unescapeURIComponent(*args)
end
