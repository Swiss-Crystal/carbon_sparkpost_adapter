# Carbon SparkPost Adapter

Integration for Lucky's [Carbon](https://github.com/luckyframework/carbon) email library and [SparkPost](https://sparkpost.com.com).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     carbon_spark_post_adapter:
       github: swiss-crystal/carbon_sparkpost_adapter
   ```

2. Run `shards install`

## Usage

Create an environment variable called `SPARK_POST_API_KEY` with your SparkPost api key.

Update your `config/email.cr` file to use SparkPost

```crystal
require "carbon_sparkpost_adapter"

BaseEmail.configure do |settings|
 if Lucky::Env.production?
   spark_post_key = send_grid_key_from_env
   settings.adapter = Carbon::SparkPostAdapter.new(api_key: spark_post_key)
 else
  settings.adapter = Carbon::DevAdapter.enw
 end
end

private def spark_post_key_from_env
  ENV["SPARK_POST_API_KEY"]? || raise_missing_key_message
end

private def raise_missing_key_message
  puts "Missing SPARK_POST_API_KEY. Set the SPARK_POST_API_KEY env variable to 'unused' if not sending emails, or set the SPARK_POST_KEY ENV var.".colorize.red
  exit(1)
end
```

## Contributing

1. Fork it (<https://github.com/Swiss-Crystal/carbon_sparkpost_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Liberatys](https://github.com/Liberatys) - maintainer
