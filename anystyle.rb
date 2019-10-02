#!/usr/bin/env ruby

require 'anystyle'
require 'multi_json'
AnyStyle.parser.normalizers[15].namae.options[:separator] = /\A(and|AND|(, )?&|;|und|UND|y|e)\s+/
x = AnyStyle.parse ARGV[0].to_s
puts MultiJson.dump(x)
