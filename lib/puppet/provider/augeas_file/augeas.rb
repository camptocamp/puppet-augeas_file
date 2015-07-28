require 'augeas' if Puppet.features.augeas?
require 'puppet/util'
require 'puppet/util/diff'

Puppet::Type.type(:augeas_file).provide(:augeas) do
  include Puppet::Util
  include Puppet::Util::Diff
  confine :feature => :augeas

  desc 'Uses the Augeas API to generate a file from a base'

  def need_apply?
    # Parse file
    base_content = File.read(resource[:base])
    @new_content = nil

    flags = Augeas::NONE
    flags = Augeas::TYPE_CHECK if resource[:type_check] == :true
    flags |= Augeas::NO_MODL_AUTOLOAD
    Augeas.open(resource[:root], resource[:load_path], flags) do |aug|
      aug.set('/input', base_content)
      aug.text_store(resource[:lens], '/input', '/parsed')
      aug.set('/augeas/context', '/parsed')

      resource[:changes].each do |c|
        # We could also do aug.srun(resource[:changes].join("\n"))
        # but error checking will be better this way
        aug.srun(c)
      end

      aug.text_retrieve(resource[:lens], '/input', '/parsed', '/output')
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
        debug "Writing content to #{f.path}"
        #debug "Content=#{@new_content}"
        f.write(@new_content)
      end
    end
  end
end
