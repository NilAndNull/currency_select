
module CurrencySelect
  class << self
    attr_accessor :currency_list

    # Returns an array with ISO codes and currency names for <tt>option</tt>
    # tags.
    def currencies_array(filter_currencies)
      if @currency_list
        @currency_list
      else
        @currencies ||= begin
          require 'money'
          Money::Currency::table.inject([]) do |array, (id, currency)|
            if filter_currencies.nil? || (filter_currencies.include?(currency[:iso_code]) == false)
              array << [ "#{currency[:name]} - #{currency[:iso_code]}", id ]
            end
            array
          end.sort_by { |currency| currency.first }
        end
      end
    end

    # Return an array with ISO codes and currency names for currency ISO codes
    # passed as an argument
    # == Example
    #   priority_currencies_array([ "USD", "NOK" ])
    #   # => [ ['United States Dollar - USD', 'USD' ], ['Norwegian Kroner - NOK', 'NOK'] ]
    def priority_currencies_array(filter_currencies,currency_codes = [])
      currency_codes.flat_map { |code| currencies_array(filter_currencies).select { |currency| currency.last.to_s == code }}
    end

  end
end

# CurrencySelect
module ActionView
  module Helpers
    module FormOptionsHelper

      # Return select and option tags for the given object and method, using
      # currency_options_for_select to generate the list of option tags.
      def currency_select(object, method, filter_currencies = nil, priority_currencies = nil, options = {}, html_options = {})
        tag = if defined?(ActionView::Helpers::InstanceTag) &&
                ActionView::Helpers::InstanceTag.instance_method(:initialize).arity != 0

          InstanceTag.new(object, method, self, options.delete(:object))
              else
                CurrencySelectTag.new(object, method, self, options)
              end
        tag.to_currency_select_tag(filter_currencies, priority_currencies, options, html_options)
      end

      # Returns a string of option tags for all available currencies. Supply
      # a currency ISO code as +selected+ to have it marked as the selected
      # option tag. You can also supply an array of currencies as
      # +priority_currencies+, so that they will be listed above the rest of
      # the list.
      def currency_options_for_select(selected = nil, filter_currencies = nil, priority_currencies = nil)
        currency_options = "".html_safe

        if priority_currencies
          currency_options += options_for_select(::CurrencySelect::priority_currencies_array(filter_currencies,priority_currencies), selected)
          currency_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n".html_safe

          # prevents selected from being included twice in the HTML which causes
          # some browsers to select the second selected option (not priority)
          # which makes it harder to select an alternative priority country
          selected = nil if priority_currencies.include?(selected)
        end

        return currency_options + options_for_select(::CurrencySelect::currencies_array(filter_currencies), selected)
      end
    end

    module ToCurrencySelectTag
      def to_currency_select_tag(filter_currencies, priority_currencies, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag('select', add_options(currency_options_for_select(value, filter_currencies, priority_currencies), options, value), html_options)
      end
    end

    if defined?(ActionView::Helpers::InstanceTag) &&
      ActionView::Helpers::InstanceTag.instance_method(:initialize).arity != 0
      class InstanceTag
        include ToCurrencySelectTag
      end
    else
      class CurrencySelectTag < Tags::Base
        include ToCurrencySelectTag
      end
    end

    class FormBuilder
      def currency_select(method, filter_currencies = nil, priority_currencies = nil, options = {}, html_options = {})
        @template.currency_select(@object_name, method, filter_currencies, priority_currencies, options.merge(:object => @object), html_options)
      end
    end

  end
end
