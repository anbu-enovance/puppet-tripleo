# Copyright 2014 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::neutron::server
#
# Neutron server profile for tripleo
#
# === Parameters
#
# [*bootstrap_node*]
#   (Optional) The hostname of the node responsible for bootstrapping tasks
#   Defaults to hiera('bootstrap_nodeid')
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::neutron::server (
  $bootstrap_node = hiera('bootstrap_nodeid', undef),
  $step           = hiera('step'),
) {
  if $::hostname == downcase($bootstrap_node) {
    $sync_db = true
  } else {
    $sync_db = false
  }

  include ::tripleo::profile::base::neutron

  # We start neutron-server on the bootstrap node first, because
  # it will try to populate tables and we need to make sure this happens
  # before it starts on other nodes
  if $step >= 4 and $sync_db {
    include ::neutron::server::notifications
    # We need to override the hiera value neutron::server::sync_db which is set
    # to true
    class { '::neutron::server':
      sync_db => $sync_db,
    }
  }
  if $step >= 5 and !$sync_db {
    include ::neutron::server::notifications
    class { '::neutron::server':
      sync_db => $sync_db,
    }
  }
}
