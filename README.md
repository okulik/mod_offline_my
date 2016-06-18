# My Ejabberd HTTP based offline module

## Overview

Whenever a message is sent to user that's currently offline, we additionally forward message to some external HTTP endpoint.

## Installation
ejabberdctl module_install ejabberd_offline_my

## Configuration

### How to enable

The simplest way is to enable mod_offline_my under modules setting in `ejabberd.yml` and setup certain configuration options.

### Configuration options

`mod_offline_my` requires some parameters to function properly. The following options should be set under `mod_offline_my` in `ejabberd.yml`:

* `host` (mandatory, `string`) - consists of protocol, hostname (or IP) and port (optional). Examples:
  * `host: "http://localhost:8080"`
  * `host: "https://services.my.com"`
* `path_prefix` (optional, default: `"/"`) - a path prefix to be
  inserted between `host` and method name; must be terminated with `/`. Examples:
  * `path_prefix: "/api/"`
