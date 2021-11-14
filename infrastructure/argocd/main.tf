/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

resource "helm_release" "argocd" {
  name                       = local.argocd_helm_app["name"]
  repository                 = local.argocd_helm_app["repository"]
  chart                      = local.argocd_helm_app["chart"]
  version                    = local.argocd_helm_app["version"]
  namespace                  = local.argocd_helm_app["namespace"]
  timeout                    = local.argocd_helm_app["timeout"]
  values                     = local.argocd_helm_app["values"]
  create_namespace           = local.argocd_helm_app["create_namespace"]
  lint                       = local.argocd_helm_app["lint"]
  description                = local.argocd_helm_app["description"]
  repository_key_file        = local.argocd_helm_app["repository_key_file"]
  repository_cert_file       = local.argocd_helm_app["repository_cert_file"]
  repository_ca_file         = local.argocd_helm_app["repository_ca_file"]
  repository_username        = local.argocd_helm_app["repository_username"]
  repository_password        = local.argocd_helm_app["repository_password"]
  verify                     = local.argocd_helm_app["verify"]
  keyring                    = local.argocd_helm_app["keyring"]
  disable_webhooks           = local.argocd_helm_app["disable_webhooks"]
  reuse_values               = local.argocd_helm_app["reuse_values"]
  reset_values               = local.argocd_helm_app["reset_values"]
  force_update               = local.argocd_helm_app["force_update"]
  recreate_pods              = local.argocd_helm_app["recreate_pods"]
  cleanup_on_fail            = local.argocd_helm_app["cleanup_on_fail"]
  max_history                = local.argocd_helm_app["max_history"]
  atomic                     = local.argocd_helm_app["atomic"]
  skip_crds                  = local.argocd_helm_app["skip_crds"]
  render_subchart_notes      = local.argocd_helm_app["render_subchart_notes"]
  disable_openapi_validation = local.argocd_helm_app["disable_openapi_validation"]
  wait                       = local.argocd_helm_app["wait"]
  wait_for_jobs              = local.argocd_helm_app["wait_for_jobs"]
  dependency_update          = local.argocd_helm_app["dependency_update"]
  replace                    = local.argocd_helm_app["replace"]

  postrender {
    binary_path = local.argocd_helm_app["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.argocd_helm_app["set"] == null ? [] : local.argocd_helm_app["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.argocd_helm_app["set_sensitive"] == null ? [] : local.argocd_helm_app["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

}
