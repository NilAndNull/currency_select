# Currency Select

Adds a currency_select helper to Ruby on Rails projects, allowing you to get a HTML select list of available currencies.

The list of currencies are provided by the [Money gem](http://money.rubyforge.org/).

## Usage Example

```ruby
# Parameters

# re_selected_currency => form object method returning an array with the pre_selected_corrency: ['usd']
# filter_currencies => array containing the currencies you dont want: ['btn']
# prirority_currencies => array containing the currencies showing at the top: ['usd','eur','gbp']
```

```ruby
# Usage

<%= f.currency_select :pre_selected_currency, filter_currencies, prirority_currencies, hash_options, hash_html_options %>
```

## Copyright

Copyright (c) 2010 Trond Arve Nordheim. See LICENSE for details.
