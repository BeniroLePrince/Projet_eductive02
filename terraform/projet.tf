resource "openstack_compute_keypair_v2" "Keypair_GRA11" {
  provider   = openstack.ovh
  name       = "sshkey_eductive02"  # Attention au XX 
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_GRA11
}

resource "openstack_compute_keypair_v2" "Keypair_SBG5" {
  provider   = openstack.ovh
  name       = "sshkey_eductive02"  # Attention au XX 
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_SBG5
}

resource "openstack_compute_instance_v2" "Instance_Backend_GRA11" {
  count       = var.i		     # Nombre d'instance par region			
  name        = "${var.instance_name_gra}_${count.index+1}"  # Nom concaténé
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_GRA11     # Nom de la régions

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.Keypair_GRA11.name

# Composant réseau par défaut	
  network {
	name = "Ext-Net"
  }
  network {
    	name = ovh_cloud_project_network_private.network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}

resource "openstack_compute_instance_v2" "Instance_Backend_SBG" {
  count       = var.i		     # Nombre d'instance par region			
  name        = "${var.instance_name_sbg}_${count.index+1}"  # Nom concaténé
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_SBG5     # Nom de la régions

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.Keypair_SBG5.name

# Composant réseau par défaut	
  network {
    name      = "Ext-Net"
  }
  network {
    	name = ovh_cloud_project_network_private.network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]

  }

resource "openstack_compute_instance_v2" "Instance_Front" {
  count       = 1	  # Nombre d'instance par region			
  name        = "${var.instance_name_front}" # nom de l'instance
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_GRA11     # Nom de la régions

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.Keypair_GRA11.name

# Composant réseau par défaut	
  network {
    name      = "Ext-Net"
  }
  network {
    	name = ovh_cloud_project_network_private.network.name
  }
   depends_on = [ovh_cloud_project_network_private_subnet.subnet]

 }

resource "ovh_cloud_project_database" "db_eductive02" {
  service_name = var.service_name
  description  = var.name_db
  engine       = "mysql"
  version      = "8"
  plan         = "essential"
  nodes {
    region = "GRA"
  }
  flavor = "db1-4"
}

resource "ovh_cloud_project_database_user" "db_eductive02" {
  service_name = ovh_cloud_project_database.db_eductive02.service_name
  engine       = "mysql"
  cluster_id   = ovh_cloud_project_database.db_eductive02.id
  name         = "user"
}

resource "ovh_cloud_project_database_database" "database" {
  service_name  = ovh_cloud_project_database.db_eductive02.service_name
  engine        = ovh_cloud_project_database.db_eductive02.engine
  cluster_id    = ovh_cloud_project_database.db_eductive02.id
  name          = "mydatabase"
}

resource "ovh_cloud_project_database_ip_restriction" "db_eductive02" {
  service_name = ovh_cloud_project_database.db_eductive02.service_name
  engine       = ovh_cloud_project_database.db_eductive02.engine
  cluster_id   = ovh_cloud_project_database.db_eductive02.id
  ip           = "${openstack_compute_instance_v2.Instance_Backend_GRA11[2].access_ip_v4}/32"
}

resource "ovh_cloud_project_database_ip_restriction" "db_eductive002" {
  service_name = ovh_cloud_project_database.db_eductive02.service_name
  engine       = ovh_cloud_project_database.db_eductive02.engine
  cluster_id   = ovh_cloud_project_database.db_eductive02.id
  ip           = "${openstack_compute_instance_v2.Instance_Backend_SBG[2].access_ip_v4}/32"
}

# Création d'un réseau privé
 resource "ovh_cloud_project_network_private" "network" {
    service_name = var.service_name
    name         = "vrack_private_network_02"  # Nom du réseau
    regions      = var.regions
    provider     = ovh.ovh                                  # Nom du fournisseur
    vlan_id      = var.vlan_id                              # Identifiant du vlan pour le vRrack
 }

resource "ovh_cloud_project_network_private_subnet" "subnet" {
    count        = length(var.regions)
    service_name = var.service_name
    network_id   = ovh_cloud_project_network_private.network.id
    start        = var.vlan_dhcp_start                          # Première IP du sous réseau
    end          = var.vlan_dhcp_end                            # Dernière IP du sous réseau
    network      = var.vlan_dhcp_network
    dhcp         = true                                         # Activation du DHCP
    region       = var.regions[count.index]
    provider     = ovh.ovh                                      # Nom du fournisseur
    no_gateway   = true                                         # Pas de gateway par defaut
 }

 resource "local_file" "inventory" {
  filename = "../ansible/inventory.yml"
  content = templatefile("inventory.tmpl",
    {
      first_instance_grav = openstack_compute_instance_v2.Instance_Backend_GRA11[0].access_ip_v4
      second_instance_grav  = openstack_compute_instance_v2.Instance_Backend_GRA11[1].access_ip_v4
      third_instance_grav = openstack_compute_instance_v2.Instance_Backend_GRA11[2].access_ip_v4
      first_instance_sbg  = openstack_compute_instance_v2.Instance_Backend_SBG[0].access_ip_v4
      second_instance_sbg  = openstack_compute_instance_v2.Instance_Backend_SBG[1].access_ip_v4
      third_instance_sbg = openstack_compute_instance_v2.Instance_Backend_SBG[2].access_ip_v4
      front = openstack_compute_instance_v2.Instance_Front[0].access_ip_v4
      frontPrivée= openstack_compute_instance_v2.Instance_Front[0].network[1].fixed_ip_v4
      mdpdb = ovh_cloud_project_database_user.db_eductive02.password
      
    }
  )
}