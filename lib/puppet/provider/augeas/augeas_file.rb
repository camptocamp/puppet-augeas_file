Puppet::Type.type(:augeas).provide(:augeas_file, :parent => Puppet::Type.type(:augeas).provider(:augeas)) do
  confine :feature => :augeas

  def need_to_run?
    # Managed by the augeas_file resource
    resource.catalog.resources.select { |r|
      if r.is_a?(Puppet::Type.type(:augeas_file)) && r[:path] == resource[:incl]
        return false
      end
    }
    super
  end
end
