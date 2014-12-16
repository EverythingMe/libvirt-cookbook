def load_current_resource
  @current_resource = Chef::Resource::LibvirtStoragePool.new(new_resource.name)
  @libvirt = ::Libvirt.open(new_resource.uri)
  @storage_pool = load_storage_pool rescue nil
  @current_resource
end

action :define do
  unless storage_pool_defined?
    storage_pool_xml = Tempfile.new(new_resource.name)
    t = template storage_pool_xml.path do
      cookbook "libvirt"
      source   "storage_pool.xml"
      variables(
        :name        => new_resource.name,
        :uuid        => ::UUIDTools::UUID.random_create,
        :path        => new_resource.path,
        :permissions => new_resource.permissions,
        :type        => new_resource.type
      )
      action :nothing
    end
    t.run_action(:create)

    @libvirt.define_storage_pool_xml(::File.read(storage_pool_xml.path))
    @storage_pool = load_storage_pool
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  require_defined_storage_pool
  unless storage_pool_active?
    @storage_pool.create
    new_resource.updated_by_last_action(true)
  end
end

action :autostart do
  require_defined_storage_pool
  unless storage_pool_autostart?
    @storage_pool.autostart = true
    new_resource.updated_by_last_action(true)
  end
end

private

def load_storage_pool
  @libvirt.lookup_storage_pool_by_name(new_resource.name)
end

def require_defined_storage_pool
  error = RuntimeError.new "You have to define storage_pool '#{new_resource.name}' first"
  raise error unless storage_pool_defined?
end

def storage_pool_defined?
  @storage_pool
end

def storage_pool_autostart?
  @storage_pool.autostart?
end

def storage_pool_active?
  @storage_pool.active?
end
