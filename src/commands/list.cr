module Redis::Commands::List
  # Insert an item at the beginning of a list, returning the number of items
  # in the list after the insert.
  #
  # ```
  # redis.del "my-list"                 # Delete so we know it's empty
  # redis.lpush "my-list", "foo", "bar" # => 2
  # redis.lpush "my-list", "foo", "bar" # => 4
  # ```
  def lpush(key, *values : String)
    run({"lpush", key} + values)
  end

  def lpush(key : String, values : Enumerable(String))
    command = Array(String).new(initial_capacity: 2 + values.size)
    command << "lpush" << key
    values.each { |value| command << value }

    run command
  end

  # Remove an item from the beginning of a list, returning the item or `nil`
  # if the list was empty.
  #
  # ```
  # redis.del "my-list" # Delete so we know it's empty
  # redis.lpush "my-list", "foo"
  # redis.lpop "my-list" # => "foo"
  # redis.lpop "my-list" # => nil
  # ```
  def lpop(key : String, count : String? = nil)
    command = {"lpop", key}
    command += {count} if count

    run(command)
  end

  def lrange(key : String, start : String, finish : String)
    run({"lrange", key, start, finish})
  end

  # Atomically remove an item from the end of a list and insert it at the
  # beginning of another. Returns that list item. If the first list is empty,
  # nothing happens and this method returns `nil`.
  #
  # ```
  # redis.del "foo"
  # redis.lpush "foo", "hello", "world"
  # redis.rpoplpush "foo", "bar" # => "hello"
  # redis.rpoplpush "foo", "bar" # => "world"
  # redis.rpoplpush "foo", "bar" # => nil
  # ```
  def rpoplpush(source : String, destination : String)
    run({"rpoplpush", source, destination})
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method returns `nil`
  #
  # ```
  # redis.lpush "foo", "hello"
  # redis.rpop "foo" # => "hello"
  # redis.rpop "foo" # => nil
  # ```
  def rpop(key : String)
    run({"rpop", key})
  end

  # Insert an item at the end of a list, returning the number of items
  # in the list after the insert.
  #
  # ```
  # redis.del "my-list"                 # Delete so we know it's empty
  # redis.rpush "my-list", "foo", "bar" # => 2
  # redis.rpush "my-list", "foo", "bar" # => 4
  # ```
  def rpush(key, *values : String)
    run({"rpush", key} + values)
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method waits the specified amount
  # of time for an element to be added to it by another connection. If the
  # element *is* added by another connection within that amount of time, this
  # method will return it immediately. If it *is not*, then this method returns
  # `nil`.
  #
  # ```
  # redis.rpush "foo", "first"
  # spawn do
  #   sleep 100.milliseconds
  #   redis.rpush "foo", "second"
  # end
  # redis.blpop "foo", 1.second # => "first"
  # redis.blpop "foo", 1.second # => "second" (after 100 milliseconds)
  # redis.blpop "foo", 1.second # => nil (after 1 second)
  # ```
  def blpop(*keys : String, timeout : Time::Span)
    blpop(*keys, timeout: timeout.total_seconds.to_i.to_s)
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method waits the specified number
  # of seconds for an element to be added to it by another connection. If the
  # element *is* added by another connection within that number of seconds,
  # this method will return it immediately. If it *is not*, then this method
  # returns `nil`.
  #
  # ```
  # redis.lpush "foo", "first"
  # spawn do
  #   sleep 100.milliseconds
  #   redis.lpush "foo", "second"
  # end
  # redis.blpop "foo", 1 # => "first"
  # redis.blpop "foo", 1 # => "second" (after 100 milliseconds)
  # redis.blpop "foo", 1 # => nil (after 1 second)
  # ```
  def blpop(*keys : String, timeout : Int | Float)
    timeout = timeout.to_i if timeout == timeout.to_i
    blpop(*keys, timeout: timeout.to_s)
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method waits the specified number
  # of seconds for an element to be added to it by another connection. If the
  # element *is* added by another connection within that number of seconds,
  # this method will return it immediately. If it *is not*, then this method
  # returns `nil`.
  #
  # ```
  # redis.lpush "foo", "first"
  # spawn do
  #   sleep 100.milliseconds
  #   redis.lpush "foo", "second"
  # end
  # redis.blpop "foo", "1" # => "first"
  # redis.blpop "foo", "1" # => "second" (after 100 milliseconds)
  # redis.blpop "foo", "1" # => nil (after 1 second)
  # ```
  def blpop(*keys : String, timeout : String)
    run({"blpop"} + keys + {timeout})
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method waits the specified amount
  # of time for an element to be added to it by another connection. If the
  # element *is* added by another connection within that amount of time, this
  # method will return it immediately. If it *is not*, then this method returns
  # `nil`.
  #
  # ```
  # redis.lpush "foo", "first"
  # spawn do
  #   sleep 100.milliseconds
  #   redis.lpush "foo", "second"
  # end
  # redis.brpop "foo", 1.second # => "first"
  # redis.brpop "foo", 1.second # => "second" (after 100 milliseconds)
  # redis.brpop "foo", 1.second # => nil (after 1 second)
  # ```
  def brpop(*keys : String, timeout : Time::Span)
    brpop(*keys, timeout: timeout.total_seconds)
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method waits the specified number
  # of seconds for an element to be added to it by another connection. If the
  # element *is* added by another connection within that number of seconds,
  # this method will return it immediately. If it *is not*, then this method
  # returns `nil`.
  #
  # ```
  # redis.lpush "foo", "first"
  # spawn do
  #   sleep 100.milliseconds
  #   redis.lpush "foo", "second"
  # end
  # redis.brpop "foo", 1 # => "first"
  # redis.brpop "foo", 1 # => "second" (after 100 milliseconds)
  # redis.brpop "foo", 1 # => nil (after 1 second)
  # ```
  def brpop(*keys : String, timeout : Number)
    timeout = timeout.to_i if timeout == timeout.to_i
    brpop(*keys, timeout: timeout.to_s)
  end

  # Remove and return an element from the end of the given list. If the list
  # is empty or the key does not exist, this method waits the specified number
  # of seconds for an element to be added to it by another connection. If the
  # element *is* added by another connection within that number of seconds,
  # this method will return it immediately. If it *is not*, then this method
  # returns `nil`.
  #
  # ```
  # redis.lpush "foo", "first"
  # spawn do
  #   sleep 100.milliseconds
  #   redis.lpush "foo", "second"
  # end
  # redis.brpop "foo", "1" # => "first"
  # redis.brpop "foo", "1" # => "second" (after 100 milliseconds)
  # redis.brpop "foo", "1" # => nil (after 1 second)
  # ```
  def brpop(*keys : String, timeout : String)
    run({"brpop"} + keys + {timeout})
  end

  def llen(key : String)
    run({"llen", key})
  end

  def lrem(key : String, count : Int, value : String)
    run({"lrem", key, count.to_s, value})
  end

  def brpop(keys : Enumerable(String), timeout : Int)
    command = Array(String).new(initial_capacity: 2 + keys.size)
    command << "brpop"
    keys.each do |key|
      command << key
    end

    command << timeout.to_s

    run command
  end
end
