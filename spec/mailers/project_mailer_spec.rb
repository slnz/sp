require 'spec_helper'

describe ProjectMailer do
  context '#team_email=' do
    it 'should work' do
      file = Object.new
      allow(file).to receive(:original_filename).and_return("original_filename")
      allow(file).to receive(:tempfile).and_return("tempfile")
      expect(File).to receive(:read).with("tempfile").and_return("contents of tempfile")
      ProjectMailer.team_email('to', 'from', 'reply_to', 'cc', [ file ], 'subject', 'body')
    end
  end
end
