require './lib/from_v2/v2_message_parser'

class Api::Hl7::V2MessageParsersController < ApplicationController
  def create
    message = request.body.read.force_encoding("utf-8")
    parser = V2MessageParser.new message
    render json: parser.to_simplify
  end
end