require 'reader'
require 'tempfile'

describe Reader do
  describe '.urls from file' do
    context 'when file does not exist' do
      it 'returns a message saying so' do
        expect(Reader.urls_from_file('an unexisting path')).to eq ('File does not exist')
      end
    end

    context 'when the file is empty' do
      before(:context) { @temp = create_tempfile('empty-file') }

      it 'processes the file and nothing else (URLs processed: 0' do
        expect(Reader.urls_from_file(@temp.path)).to be 0
      end

      after(:context) { close_file(@temp) }
    end

    context 'when the file has some content' do
      before(:context) do
        @temp = create_tempfile('some-content-file')
        5.times { |i| @temp.write("https://some-url-#{i}/with-rss\n") }
        @temp.rewind
      end

      it 'processes the file and the URLs' do
        expect(Reader.urls_from_file(@temp.path)).to be > 0
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
end