require 'reader'
require 'tempfile'
require 'stringio'

describe Reader do
  describe '::from_file' do
    context 'when file does not exist' do
      it 'returns a message saying so' do
        expect(Reader.from_file('an unexisting path')).to eq ('File does not exist')
      end
    end

    context 'when the file is empty' do
      before(:context) { @temp = create_tempfile('empty-file') }

      it 'processes the file and nothing else (URLs processed: 0' do
        expect(Reader.from_file(@temp.path)).to be 0
      end

      after(:context) { close_file(@temp) }
    end

    context 'when the file has some content' do
      before(:context) do
        @temp = create_tempfile('some-content-file')
        5.times { |i| @temp.write(mockup_url(i)) }
        @temp.rewind
      end

      it 'processes the file and the URLs' do
        5.times { |i| stub_request(:get, mockup_url(i)) }
        expect(Reader.from_file(@temp.path)).to be > 0
      end

      after(:context) { close_file(@temp) }
    end

    def close_file(file)
      File.unlink(file.path)
    end

    def create_tempfile(name)
      Tempfile.create([name, '.txt'], '/tmp/' )
    end
  end

  describe '::from_console' do
    context 'when the input is blank' do
      it 'finishes the processing' do
        allow(Reader).to receive(:handle_input).and_return('')
        expect(Reader.from_console).to be_nil
      end
    end

    context 'when the input is not a URL' do
      it 'raises the exception' do
        allow(Reader).to receive(:handle_input).and_return('NOT a URL')
        expect(Reader.from_console).to eq('The url was treated as a directory')
      end
    end

    context 'when the input is an invalid URL' do
      it 'raises the exception' do
        url = 'https://www.not-a-valid.to/'
        stub_request(:get, url).and_raise(SocketError)
        allow(Reader).to receive(:handle_input).and_return(url)
        expect(Reader.from_console).to eq('There was a problem opening the URL')
      end
    end

    context 'when the URL is valid but the XML is not' do
      it 'raises the RSS Parser Exception' do
        url = 'https://www.ruby-lang.org/en/feeds/news.rss'
        stub_request(:get, url).and_return('<xml><channel></item></xml>')
        allow(Reader).to receive(:handle_input).and_return(url)
        expect(Reader.from_console).to eq('RSS was Invalid')
      end
    end

    context 'when the input keeps coming' do
    end
  end
end

def mockup_url(index)
  "https://some-url-#{index}/with-rss\n"
end