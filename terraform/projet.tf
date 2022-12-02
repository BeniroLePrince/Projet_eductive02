resource "openstack_compute_keypair_v2" "keypair_GRA11" {
  provider   = openstack.ovh
  name       = "sshkey_eductive02"  # Attention au XX ;)
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_GRA11
}

resource "openstack_compute_instance_v2" "Projet_terraform" {
  count       = 3		
  name        = "${var.instance_name_gra}_${count.index+1}"  # Nom concaténé
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_GRA11     # Nom de la régions

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.keypair_GRA11.name

# Composant réseau par défaut	
  network {
    name      = "Ext-Net"
  }
 }
