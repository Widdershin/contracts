Hacked together a contracts implementation in Ruby.

```ruby
require './contracts'

class Test
  extend Contracts

  add_contract { |num| num.respond_to? :to_i }
  .and         { |num| num < 100 }
  .to def is_even?(num)
    num % 2 == 0
  end

  add_contract { |array| array.respond_to? :to_a }
  .and         { |array| array.all? { |i| i.is_a? Numeric } }
  .and_ensure  { |result| result.all? { |i| i % 2 == 0 } }
  .to def times_by_two(array)
    array.map { |i| i * 3 }
  end
end

begin
  p Test.new.is_even?(10)
  p Test.new.is_even?(500)
rescue Exception => e
  puts e.message
end

begin
  p Test.new.times_by_two([1, 2, 3, 4])
rescue Exception => e
  puts e.message
end
```

```
$ test.rb

[]

Return contract on Test#is_even? failed:

 num < 100

Args: [500]


Return contract on Test#times_by_two failed:

 result.all? { |i| i % 2 == 0 }

Return value: [3, 6, 9, 12]
Args: [[1, 2, 3, 4]]
```
