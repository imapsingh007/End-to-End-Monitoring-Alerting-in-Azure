# ---------- 1) Resource Group ----------
resource "azurerm_resource_group" "mon" {
  name     = var.resource_group_name
  location = var.location
}

# ---------- 2) Log Analytics Workspace ----------
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${azurerm_resource_group.mon.name}"
  location            = azurerm_resource_group.mon.location
  resource_group_name = azurerm_resource_group.mon.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---------- 3) Application Insights ----------
resource "azurerm_application_insights" "ai" {
  name                = "appinsights-${random_string.rand.result}"
  location            = azurerm_resource_group.mon.location
  resource_group_name = azurerm_resource_group.mon.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

resource "random_string" "rand" {
  length  = 5
  upper   = false
  special = false
}

# ---------- 4) Action Group (e‑mail + SMS) ----------
resource "azurerm_monitor_action_group" "notify" {
  name                = "mon‑ag"
  resource_group_name = azurerm_resource_group.mon.name
  short_name          = "MONAG"
  email_receiver {
    name          = "email"
    email_address = var.action_group_email
  }
  dynamic "sms_receiver" {
    for_each = var.action_group_sms == null ? [] : [var.action_group_sms]
    content {
      name         = "sms"
      country_code = "+"  # include the + in your variable
      phone_number = sms_receiver.value
    }
  }
}

# ---------- 5) Metric Alert (CPU > 80 %) ----------
resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "cpu-high-alert"
  resource_group_name = azurerm_resource_group.mon.name
  scopes              = [azurerm_application_insights.ai.id]
  description         = "AppInsights CPU usage over 80 % (5‑min average)"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = azurerm_monitor_action_group.notify.id
  }
}
