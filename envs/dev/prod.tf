/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "google_compute_network" "landing-tier-vpn" {
  name    = "${local.env}-01-con-vpc01"
  project = data.google_projects.landing_zone_project.projects[0].project_id
}
##To MGMT VPC
module "vpn-ha-to-mgmt" {
  source           = "../../modules/vpn_ha"
  project_id       = local.landing_zone_project_id
  region           = var.default_region1
  network          = data.google_compute_network.landing-tier-vpn.self_link
  name             = "landing-tier-to-on-prem"
  router_asn       = 64513
  peer_gcp_gateway = module.vpn-ha-to-prod.self_link
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = 64514
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.1.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = null
      shared_secret                   = module.vpn-ha-to-prod.random_secret
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = 64514
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.2.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = null
      shared_secret                   = module.vpn-ha-to-prod.random_secret
    }
  }
}

