require 'augeas' if Puppet.features.augeas?
require 'puppet/util'
require 'puppet/util/diff'

Puppet::Type.type(:augeas_file).provide(:augeas) do
  include Puppet::Util
  include Puppet::Util::Diff
  confine :feature => :augeas

  desc 'Uses the Augeas API to generate a file from a base'

  def need_to_apply?
    # Parse file
    base_content = File.read(resource[:base])
    @new_content = nil

    augeas_resources = resource.catalog.resources.select { |r|
      r.is_a?(Puppet::Type.type(:augeas)) && r[:incl] == resource[:name]
    }

    augeas_lenses = augeas_resources.map { |r|
      r[:lens]
    }.uniq

    fail "More than one lens found to manage #{resource[:path]}" if augeas_lenses.length > 1
    lens = resource[:lens] || augeas_lenses[0]

    flags = Augeas::NONE
    flags = Augeas::TYPE_CHECK if resource[:type_check] == :true
    flags |= Augeas::NO_MODL_AUTOLOAD
    Augeas.open(resource[:root], resource[:load_path], flags) do |aug|
      aug.set('/input', base_content)
      succ = aug.text_store(lens, '/input', '/parsed')
      unless succ
        err = aug.get('/augeas//error/message')
        raise Puppet::Error, "Failed to parse content:\n#{err}"
      end
      aug.set('/augeas/context', '/parsed')

      resource[:changes].each do |c|
        # We could also do aug.srun(resource[:changes].join("\n"))
        # but error checking will be better this way
        aug.srun(c)
      end

      # Changes from augeas resources
      augeas_resources.each do |r|
        Puppet.debug("Applying changes for augeas resource \"#{r[:name]}\"")
        r[:changes].each do |c|
          aug.srun(c)
        end
      end

      succ = aug.text_retrieve(lens, '/input', '/parsed', '/output')
      unless succ
        err = aug.get('/augeas//error/message')
        raise Puppet::Error, "Failed to get modified content:\n#{err}"
      end
      @new_content = aug.get('/output')
    end
    cur_content = File.read(resource[:path]) if File.file?(resource[:path])
    cur_content != @new_content
  end

  def write_changes
    if Puppet[:show_diff] && @resource[:show_diff]
      Tempfile.open('augeas_file') do |t|
        t.write(@new_content)
        t.close
        self.send(@resource[:loglevel], "\n" + diff(resource[:path], t.path))
      end
    end

    unless resource.noop?
      File.open(resource[:path], 'w') do |f|
        f.write(@new_content)
      end
    end
  end
end
