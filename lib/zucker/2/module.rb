class Module  
  def alias_methods *methods
    raise ArgumentError, "Must take at least an alias and an existing method as arguments" if methods.size < 2
    last_method = methods.last                         
    keys = [:from, :aliasing, :original]

    original_method = if last_method.kind_of?(Hash) 
      method = keys.map{|k| last_method[k]}.compact.first 
      raise ArgumentError, "The option key must be one of #{keys.inspect} " if !method
      method      
    else
      last_method.to_sym
    end    
    methods[0..-2].each do |method| 
      module_eval do
        if responds_to? :alias_method
          alias_method method.to_sym, original_method
        else
          eval "alias #{method.to_sym} #{original_method}"
        end
      end
    end
    true
  end
end             
