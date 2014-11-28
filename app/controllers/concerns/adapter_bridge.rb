require 'future'

module AdapterBridge

  def call_async(url, **options)
    future { self.class.get url, options }
  end
  
  # For testing purposes (since byebug locks the CPU we cannot have async calling for
  # resources).
  def call(url, **options)
    self.class.get url, options
  end

end
