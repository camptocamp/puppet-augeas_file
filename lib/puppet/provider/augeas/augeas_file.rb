Puppet::Type.type(:augeas).provide(:augeas_file, :parent => Puppet::Type.type(:augeas).provider(:augeas)) do
  confine :feature => :augeas
  # Hijack the augeas provider
  defaultfor :feature => :augeas

  def need_to_run?
    # Managed by the augeas_file resource
    resource.catalog.resources.each { |r|
      if r.is_a?(Puppet::Type.type(:augeas_file)) && r[:path] == resource[:incl]
        Puppet.debug("Not applying individual augeas resource '#{resource[:name]}' as there is a matching augeas_file")
        return false
      end
    }
    super
  end
end
