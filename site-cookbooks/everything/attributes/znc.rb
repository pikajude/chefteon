default['znc']['port'] = 54321
default['znc']['allow_ssl'] = false
default['znc']['user'] = {
  account: "joelteon",
  nick: "joelteon",
  nick_alt: "joelteon_",
  ident: "bzzt",
  real_name: "Joel",
  quit_message: "goodbye"
}

default['znc']['networks'] = {
  freenode: {
    address: "irc.freenode.net",
    port: 6667,
    channels: %w{
      #oftn #elliottcable #haskell #haskell-lens #yesod #digitalocean #vim
      #ghc #docker #travis #reddit-mfa #haskell-blah #go-nuts
    }
  },
  mountai: {
    address: "irc.mountai.net",
    nick: "otters",
    away_nick: "otters`away",
    channels: %w{#n #music}
  },
  mozilla: {
    address: "irc.mozilla.org",
    channels: %w{#rust}
  },
  rizon: {
    address: "irc.rizon.net",
    nick: "owls",
    away_nick: "owls`away",
    channels: %w{#sphb #phl}
  }
}
