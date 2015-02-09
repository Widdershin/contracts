require 'sourcify'

module Contracts
  def contracts
    @contracts ||= []
  end

  def add_contract(&block)
    contracts << Contract.new(
      self
    )

    contracts.last
  end


  def bind_contracts(contracts, post_contracts, method)
    alias_method "_replaced_#{method}".to_sym, method
    define_method(method) do |*args|

      contracts.each do |contract|
        raise "\nReturn contract on #{self.class}##{method} failed:\n\n #{contract.to_raw_source(:ignore_nested => true, :strip_enclosure => true)}\n\nArgs: #{args}" unless !!contract.call(*args)
      end

      return_value = send "_replaced_#{method}".to_sym, *args

      post_contracts.each do |contract|
        raise "\nReturn contract on #{self.class}##{method} failed:\n\n #{contract.to_raw_source(:ignore_nested => true, :strip_enclosure => true)}\n\nReturn value: #{return_value}\nArgs: #{args}" unless !!contract.call(return_value)
      end
    end
  end
end

class Contract
  attr_reader :wrapped_object
  attr_writer :args

  def initialize(wrapped_object, contracts = [], post_contracts = [])
    @wrapped_object = wrapped_object
    @contracts = contracts
    @post_contracts = post_contracts
  end

  def to(method)
    @wrapped_object.bind_contracts(@contracts, @post_contracts, method)
  end

  def and(&block)
    self.class.new(
      @wrapped_object,
      @contracts + [block.to_proc]
    )
  end

  def and_ensure(&block)
    self.class.new(
      @wrapped_object,
      @contracts,
      @post_contracts + [block.to_proc]
    )
  end
end 
