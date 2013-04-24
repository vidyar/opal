class Native < BasicObject

  def self.global
    @global ||= Native.new(`Opal.global`)
  end

  def self.[](key)
    global[key]
  end

  def initialize(native)
    %x{
      if (#{native} == null) {
        #{ Kernel.raise "null or undefined passed to Native" };
      }
    }

    @native = native
  end

  def method_missing(symbol, *args, &block)
    native = @native

    %x{
      var prop = #{native}[#{symbol}];

      if (typeof(prop) === 'function') {
        return prop.apply(#{native}, #{args});
      }
      else if (symbol.charAt(symbol.length - 1) === '=') {
        prop = symbol.slice(0, symbol.length - 1);
        return #{native}[prop] = args[0];
      }
      else if (prop != null) {
        if (typeof(prop) === 'object') {
          if (!prop._klass) {
            return #{Native.new `prop`};
          }
        }
        return prop;
      }
    }

    nil
  end

  def [](key)
    %x{
      var value = #{@native}[key];

      if (value == null) return #{nil};

      return value;
    }
  end

  def ==(other)
    `#{@native} === #{other}.native`
  end

  def to_native
    @native
  end
end
