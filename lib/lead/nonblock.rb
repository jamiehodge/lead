module Lead
  module Nonblock

    def read(io:, bytes: 4096)
      io.read_nonblock(bytes)
    rescue IO::WaitReadable
      IO.select([io])
      retry
    end

    def write(io:, data:)
      io.write_nonblock(data)
    rescue IO::WaitWritable, Errno::EINTR
      IO.select(nil, [io])
      retry
    end

    def accept(io:)
      io.accept_nonblock
    rescue IO::WaitReadable, Errno::EINTR
      IO.select([io])
      retry
    end
  end
end
