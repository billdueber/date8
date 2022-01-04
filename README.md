# Date8 -- deal with dates of the form YYYYMMDD and filenames that embed them

----

**Deprecated and archived.**: See [date_named_file](https://github.com/billdueber/date_named_file) for the more generic approach.

----

My work involves an embarrassing amount of passing around dated files, 
usually something like `catalog_update_20191103.txt.gz` or the like. This 
library just allows me to be a little lazier when doing so.

It's clearly not a generic date gem, just some sugar on top of
the `Date` class from the standard library.

## Usage

### Dealing with files that follow a pattern

```ruby

require 'date8'

update_file_template = Date8::FileTemplate("dat_upd_<%Y%m%d>.csv")

# Give it something that we can parse to a Date8
update_file_template(20191101)
#=> "dat_upd_20191101.csv"

#...or a Date8 object itself
update_file_template(Date8.yesterday)
#=> dat_upd_20191031.csv

data_dir = '/usr/local/dataloads'
#
# Suppose we have a mix of update and full-file data files
# ls /usr/local/dataloads
#
# dat_full_20191001.csv.gz dat_full_20191101.csv.gz 
# dat_upd_20191106.csv     dat_upd_20191107.csv
# dat_upd_20191108.csv     dat_upd_20191109.csv
# dat_upd_20191110.csv     dat_upd_20191111.csv

update_files = update_file_template.in(data_dir)

update_files.count #=> 6
update_files.oldest #=> dat_upd_20191106.csv
update_files.newest #=> dat_upd_20191111.csv

# Find the files including and after a given date
update_files.since(20191109) 
#=> ["dat_upd_20191109.csv", "dat_upd_20191110.csv", "dat_upd_20191111.csv"]

# Get those *just* after the date
update_files.after(20191109) 
#=> ["dat_upd_20191110.csv", "dat_upd_20191111.csv"]

# Do we have one from the 3rd?
update_files.exist?(20191003) #=> false

# How about those full files?
full_files = Date8::FileTemplate('dat_full_<DATE>.csv.gz').in(data_dir))

# Do we have a full file from this month?
full_files.select {|ff| f.month == Date8.today.month}
#=> ['dat_full_20191101.csv.gz']

# All the update files newer than the latest full file
update_files.select {|uf| uf > full_files.newest}

```

### Dealing with just the dates 

Most of this is just standard `Date` behavior, with some sugar and the
notable difference that the string representation is always YYYYMMDD

```ruby

require 'date8'

dt = Date8.new(20191101)
dt = Date8.new("2019-11-01")
dt = Date8.new("20191101")

puts dt
#=> 20191101

# A few ways to get "today"
today = Date8.today
today = Date8.now # to mimic DateTime
today = Date8.new # no args

# Sugar for yesterday and tomorrow, too 

yesterday = Date8.yesterday
tomorrow = Date8.tomorrow 

# Assume it's November
halloween = Date8.last_day_of_last_month
the_first = Date8.first_day_of_this_month

# Arithmetic is in days

halloween = the_first - 1
all_saints_day = halloween + 1

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'date8'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install date8

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/billdueber/date8.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
