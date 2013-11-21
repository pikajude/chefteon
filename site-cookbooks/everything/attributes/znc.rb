default['znc']['port'] = 54321
default['znc']['allow_ssl'] = false
default['znc']['user'] = {
  :account => "joelteon",
  :nick => "joelteon",
  :nick_alt => "joelteon_",
  :ident => "bzzt",
  :real_name => "Joel"
}

default['znc']['networks'] = [
  {
    :name => "freenode",
    :address => "irc.freenode.net",
    :port => "6667",
    :channels => %w{#haskell}
  }
]
