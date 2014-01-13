#encoding:utf-8
require "http/parser"

module EventMachine
  module WebSocket
    module Handshake99
      include EM::Deferrable
      def initialize
        (@parser = Http::Parser.new).on_headers_complete = proc { |headers|
          @headers = Hash[headers.map { |k,v| [k.downcase, v] }]
        }
      end
      def headers
        @parser.headers
      end
      def headers_downcased
        @headers
      end
      def path
        @parser.request_path
      end
      def self.handshake(headers, path, secure)
        return ''
      end
    end
  end
end
