Puppet::Type.newtype(:augeas_file) do
  @doc = 'Manage a file from a template and Augeas changes'

  newparam(:path, :namevar => true) do
    desc 'The path to the target file'
  end

  newparam(:base) do
    desc 'The path to the base file'
  end

  newparam(:lens) do
    desc 'The Augeas lens to use'
  end

  newparam(:root) do
    desc "A file system path; all files loaded by Augeas are loaded underneath `root`."
    defaultto "/"
  end

  newparam(:load_path) do
    desc "Optional colon-separated list or array of directories; these directories are searched for schema definitions. The agent's `$libdir/augeas/lenses` path will always be added to support pluginsync."
    defaultto ""
  end

  newparam(:type_check, :boolean => true) do
    desc "Whether augeas should perform typechecking. Defaults to false."

    defaultto :false
  end

  newparam(:show_diff, :boolean => true) do
    desc "Whether to display differences when the file changes, defaulting to
        true.  This parameter is useful for files that may contain passwords or
        other secret data, which might otherwise be included in Puppet reports or
        other insecure outputs.  If the global `show_diff` setting
        is false, then no diffs will be shown even if this parameter is true."

    defaultto :true
  end

  newparam(:changes) do
    desc 'The array of changes to apply to the base file'

    defaultto []

  end

  # This is the actual meat of the code. It forces
  # augeas to be run and fails or not based on the augeas return
  # code.
  newproperty(:returns) do
    include Puppet::Util
    desc "The Augeas output. Should not be set."

    defaultto 0

    # Make output a bit prettier
    def change_to_s(currentvalue, newvalue)
      "content successfully replaced"
    end

    def retrieve
      provider.need_apply? ? :need_to_run : 0
    end

    # Actually execute the command.
    def sync
      @resource.provider.write_changes
    end
  end
end
