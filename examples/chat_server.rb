#encoding:utf-8
require 'em-websocket'
require 'json'
require 'cgi'
require 'zlib'

MSG_MAX_LENGTH = 30


#use mask code will be speedup(same object)

module EventMachine
  module Wslp
    class Connection < EventMachine::Connection
      @@nodes = []
      
      alias :node_id :signature

      def initialize(options)
        
        @onopen = Proc.new do |handshake|
          @@nodes << self
          puts "open"
          #port , remote_ip = Socket.unpack_sockaddr_in(self.get_peername)
          #path = handshake.path
          
          #long_polling : send => close , non-send => sleep
          if self.long_polling
            #handshake.query  => url params
            #handshake.body   => post params
            #handshake.params => (url params).merge(post params)
            #handshake.parser.http_method => ["GET" , "POST" , "MIXED" ...][N]
            
            #...
            
            if !handshake.body.empty?
              broadcast(handshake.body['msg'])
            else
              #keep connection
            end
            
          #websocket
          else
            #...
          end
        end
        
        #websocket disconnect or long polling (disconnect || send)
        @onclose = Proc.new do
          puts 'close'
          @@nodes.delete_if{|node|node.node_id == self.node_id}
          
          #long polling
          if(self.long_polling)
            #...

          #websocket
          else
            #...
          end
        end
        
        #websocket only
        @onmessage = Proc.new do |msg|
          broadcast(msg)
        end
        
        def broadcast(msg)
          msg = {:msg => "#{Time.now.strftime('%H:%M:%S')} : #{msg}"}.to_json
          
          @@nodes.each do |node|
            node.send_text(msg)
          end
        end
      end
    end
  end
end

SERVER_CONFIG = {:host => '0.0.0.0' , :port => 3456}

puts "init_server : #{SERVER_CONFIG}"

EventMachine::run do
  EventMachine::Wslp.start(SERVER_CONFIG) do |ws|
    
# you can use this way like em-websocket
=begin
    ws.onopen do |handshake|
      ...
    end
    ws.onclose do
      ...
    end
    ws.onmessage do |msg|
      ...
    end
=end
  end
end