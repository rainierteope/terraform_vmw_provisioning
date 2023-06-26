data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  count         = var.cluster != null ? 1 : 0
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  count         = var.cluster != "" ? 0 : 1
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "res_pool" {
  name          = var.cluster != "" ? "${var.cluster}/Resources" : "${var.host}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networks" {
  count         = length(var.networks)
  name          = trimspace(split(":", (var.networks)[count.index])[0])
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "folder" {
  count = var.folder != null ? 1 : 0
  path  = "${data.vsphere_datacenter.dc.name}/vm/${var.folder}"
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  # Instance details
  count            = var.instances
  name             = "${upper(var.name)}00${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.res_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder

  # Instance hardware specs
  num_cpus = local.sizes[var.size].cpu
  memory   = local.sizes[var.size].memory

  # Instance hardware specs from template
  firmware = data.vsphere_virtual_machine.template.firmware
  guest_id = data.vsphere_virtual_machine.template.guest_id
  cpu_hot_add_enabled = data.vsphere_virtual_machine.template.cpu_hot_add_enabled
  memory_hot_add_enabled = data.vsphere_virtual_machine.template.memory_hot_add_enabled
  hardware_version = data.vsphere_virtual_machine.template.hardware_version
  efi_secure_boot_enabled = data.vsphere_virtual_machine.template.efi_secure_boot_enabled
  
  # Waiter configuration
  wait_for_guest_net_timeout  = 5

  # Virtual disk configuration
  dynamic "disk" {
    for_each = toset([ for i in range(length(var.disks)) : i ])
    content {
      label       = "disk${disk.key}"
      size        = var.disks[disk.key]
      unit_number = disk.key
    }
  }

  # Virtual network adapters configuration
  dynamic "network_interface" {
    for_each = toset([ for i in range(length(var.networks)) : i ])
    content {
      network_id = data.vsphere_network.networks[network_interface.key].id
    }
  } 

  # Cloning options
  clone {
    template_uuid = data.vsphere_virtual_machine.template.uuid
    customize {
      dynamic "linux_options" {
        for_each = var.isWindows == false ? [1] : []
        content {
          host_name = "${upper(var.name)}00${count.index + 1}"
          domain    = var.domain
        }
      }

      dynamic "windows_options" {
        for_each = var.isWindows == false ? [] : [1]
        content {
          computer_name = "${upper(var.name)}00${count.index + 1}"
        }
      }

      dynamic "network_interface" {
        for_each = toset([ for i in range(length(var.networks)) : i ])
        content {
          ipv4_address = split("/", [ for network in split(",", split(":", var.networks[network_interface.key])[1]) : trimspace(network)][count.index])[0]
          ipv4_netmask = split("/", [ for network in split(",", split(":", var.networks[network_interface.key])[1]) : trimspace(network)][count.index])[1]
        }
      }
      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = var.dns_server_list
    }
  }
}