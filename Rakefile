require 'rake'
require 'yaml'

# Load config
@config=YAML.load(File.read("lab.yml"))
puts YAML.dump(@config)

# Globals from config
@prefix=@config["prefix"]
@vms=@config["vms"].keys.sort

desc "Prepare Lab"
task :prepare_lab do |t|
	puts "Downloading ISO installation image"
	%x[mkdir -p images]
	%x[cd images ; wget #{@config["images"]["default"]["url"]} -O #{@config["images"]["default"]["name"]}]
end

desc "Create instances"
task :init_vms do |t|
	 @vms.each do |vm|
		name=vm
		next if name=="#{@prefix}.admin"
		ram=@config["vms"][vm]["ram"]
		cpus=@config["vms"][vm]["cpus"]
		options=@config["vms"][vm]["options"]
		bridge=@config["vms"][vm]["bridge"]
		vm_dir="vm/#{@prefix}.#{vm}"
		disk_entry=generate_disk_entries(vm)
		net_entry=generate_net_entries(vm)
                puts "Creatig instance #{@prefix}.#{vm}"
		%x[mkdir -p #{vm_dir}]
		#create_user_data(vm)
		#create_meta_data(vm)
		#%x[cd #{vm_dir} ; genisoimage -output cidata.iso -volid cidata -joliet -r meta-data user-data]
		#%x[cp images/#{@config["images"]["default"]["name"]} #{vm_dir}/#{vm}.qcow2]
		%x[sudo virt-install --pxe --boot network,hd,menu=on --name #{@prefix}.#{vm} --ram #{ram} --vcpus #{cpus} #{disk_entry} #{net_entry} --os-variant=sles12 --noautoconsole #{options}]
	end
end

desc "Init vm subvolume"
task :init_vm_sub do |t|
	%x[btrfs subvolume create vm]
end

desc "Create snapshot"
task :snap_create, [:name] do |t,args|
	%x[test -d .snapshots || mkdir -p .snapshots]
	%x[btrfs subvolume snapshot -r vm .snapshots/#{args[:name]}]
end

desc "List snapshot"
task :snap_list do |t,args|
	system("btrfs subvolume list -s .")
end

desc "Save VM status"
task :save_state do |t|
	@vms.each do |vm|
		puts "Saving #{@prefix}.#{vm}"
		%x[sudo virsh dumpxml #{@prefix}.#{vm}  > vm/#{vm}/#{vm}.xml]
	end
end

desc "Start lab virtual machines"
task :start_vms do |t|
	@vms.each do |vm|
		puts "Starting #{@prefix}.#{vm}"
		%x[sudo virsh start #{@prefix}.#{vm}]
		system("sleep 5")
	end
end

desc "Stop lab virtual machines"
task :stop_vms do |t|
	@vms.each do |vm|
		puts "Stopping #{@prefix}.#{vm}"
		%x[sudo virsh shutdown #{@prefix}.#{vm}]
	end
end

desc "destroy lab virtual machines"
task :destroy_vms do |t|
	@vms.each do |vm|
		puts "Destroy #{@prefix}.#{vm}"
		%x[sudo virsh destroy #{@prefix}.#{vm}]
	end
end

desc "undefine lab virtual machines"
task :undefine_vms do |t|
	@vms.each do |vm|
		puts "Undefine #{@prefix}.#{vm}"
		%x[sudo virsh undefine #{@prefix}.#{vm}]
	end
end


desc "Setup DNAT for external access"
task :set_dnat do |t|
    # Setup SSH access (port 2X22, X: instance number) 
    system "sudo iptables -t nat -A PREROUTING -i br0 -p tcp --dport 2#{@instance}22 -j DNAT --to 192.168.122.1#{@instance}:22"
    # Setup vnc access (port 590X, X: instance number ) 
    system "sudo iptables -t nat -A PREROUTING -i br0 -p tcp --dport 590#{@instance} -j DNAT --to 192.168.122.1#{@instance}:5900"
    # Accept forward
    system "sudo iptables -I FORWARD -i br0 -o virbr0 -j ACCEPT"
end

desc "Unset DNAT for external access"
task :unset_dnat do |t|
    # Setup SSH access (port 2X22, X: instance number) 
    system "sudo iptables -t nat -D PREROUTING -i br0 -p tcp --dport 2#{@instance}22 -j DNAT --to 192.168.122.1#{@instance}:22"
    # Setup vnc access (port 590X, X: instance number ) 
    system "sudo iptables -t nat -D PREROUTING -i br0 -p tcp --dport 590#{@instance} -j DNAT --to 192.168.122.1#{@instance}:5900"
    # Accept forward
    system "sudo iptables -D FORWARD -i br0 -o virbr0 -j ACCEPT"
end

#### Aux functions

# Generate disk entries for virt-install
def generate_disk_entries(vm)
	entry=""
	i=1
	vm_dir="vm/#{@prefix}.#{vm}"
	@config["vms"][vm]["disks"].keys.sort.each do |disk|
		size=@config["vms"][vm]["disks"][disk]["size"]
		entry+=" --disk #{vm_dir}/#{vm}-disk#{i}.qcow2,format=qcow2,bus=virtio,size=#{size}"
		i+=1
	end
	entry
end

# Generate disk entries for virt-install
def generate_net_entries(vm)
	entry=""
	@config["vms"][vm]["net"].keys.sort.each do |intf|
		mac=@config["vms"][vm]["net"][intf]["mac"]
		bridge=@config["vms"][vm]["net"][intf]["bridge"]
		entry+=" --network bridge=#{bridge},model=virtio,mac=#{mac}"
	end
	entry
end


# Creates cloud-init meta-data
def create_meta_data(vm)
	puts @config["vms"][vm]
	File.open("vm/#{@prefix}.#{vm}/meta-data","w") do |f|
		f.puts <<__EOB__
instance-id: #{vm}
local-hostname: #{vm}
network-interfaces: |
  auto eth0
  iface eth0 inet static
  address #{@config["vms"][vm]["ip"]}
  netmask #{@config["vms"][vm]["netmask"]}
  gateway #{@config["vms"][vm]["gateway"]}
__EOB__
	end
end

# Creates cloud-init user-data
def create_user_data(vm)
	File.open("vm/#{@prefix}.#{vm}/user-data","w") do |f|
		f.puts <<__EOB__
#cloud-config

# Hostname management
preserve_hostname: False
hostname: #{vm}
fqdn: #{vm}.kubernetes.clab.lan

# Remove cloud-init when finished with it
runcmd:
  - [ yum, -y, remove, cloud-init ]

# configure interaction with ssh server
ssh_svcname: ssh
ssh_deletekeys: True
ssh_genkeytypes: ['rsa', 'ecdsa']

# Install my public ssh key to the first user-defined user configured 
# in cloud.cfg in the template (which is centos for CentOS cloud images)
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBslD3aryvHxSdxmO05oJf/tLQsj9EFdj78w1kfKKji3DtQV32rww3nTboHYeOZ93RmAqfhmgj0YAOGcejsiAvoatBqV29/QCsjwJrhDUPRhk7OXbEEWThcG69xQUnpkE3KzpbbgqstQgVogXMsHWuuanGvqGeH2FZcYlL43mi75fsWcUlrkCFmYPLv2LfyjLvAr8OFjkUnCNGkkmxSGm2rGWSJ7q0jf6ZpFYhOBsBotRKVWL4O8WHlhhvCJuRluTvszYmdOuxaMAuAhQlMRyw+RSjxSaQOtQirHeo7WEhyyMNabT8g4RCr8nkp71PH20NcPtw7kKBzo837qwzTEw9 kuko@portatil-kuko

__EOB__
	end
end
