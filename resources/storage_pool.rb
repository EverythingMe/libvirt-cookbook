actions :define, :create, :autostart
default_action :define

attribute :type, :kind_of => String
attribute :path, :kind_of => String
attribute :permissions, :kind_of => Hash
attribute :uri, :kind_of => String, :default => 'qemu:///system'
