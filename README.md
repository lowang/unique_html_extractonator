# UniqueHtmlExtractonator

Extract unique content from HTML using reference_html for comparison.
Designed to extract only significant content from page with layout,
skipping all common elements like header or footer.
  
why Extractonator? Because my team loves all project ending with "-nator" ;-) 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unique_html_extractonator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unique_html_extractonator

## Usage

```ruby
UniqueHtmlExtractonator::Extractor.new(reference_html: reference_html_as_string, html: html_to_extract_as_string).extract
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/lowang/unique_html_extractonator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
