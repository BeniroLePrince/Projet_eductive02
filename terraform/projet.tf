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
    name      = "Ext-Net"
  }
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
 }

resource "openstack_compute_instance_v2" "Instance_Front" {
  count       = 1		     # Nombre d'instance par region			
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
 }
