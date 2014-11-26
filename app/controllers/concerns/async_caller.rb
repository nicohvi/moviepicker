module AsyncCaller

  def call_async(url, **options)
    future { self.class.get url, options }
  end

end
