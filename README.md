# Backstop::Deploys

An extension to backstop to allow submission to Librato Metrics

## Installation

Add this line to your application's Gemfile:

    gem 'backstop-deploys'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backstop-deploys

## Usage

Run `Backstop::Deploys::Web` in your rack application.

Assumes the pressence of `LIBRATO_EMAIL` and `LIBRATO_KEY` in `ENV`.

Example curl interaction:

```bash
$ curl -X PUT localhost:5000/deploys/my_app.v73.1350581323 -d 'source=production&end_time=1350581423'
```

The resource id is broken down into `component.version.epoch_time`.  `source` is required in the body and represents the environment that is reporting the deploy, `end_time` is optional.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
