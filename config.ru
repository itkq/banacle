require 'banacle'

config = Banacle::Config.new(
  slack_signing_secret: ENV.fetch('BANACLE_SLACK_SIGNING_SECRET'),
)

run Banacle.app(config)
