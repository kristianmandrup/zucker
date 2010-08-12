class Module  
  def alias_methods_for original_method, *alias_methods
    # module_eval do
    #   raise ArgumentError, "The method #{original_method} you try to alias does not exist here #{self}" if !respond_to? original_method.to_s
    # end    
    alias_methods.each do |method| 
      class_eval do
        eval "alias #{method.to_s} #{original_method.to_s}"
      end
    end
    true
  end
end             

