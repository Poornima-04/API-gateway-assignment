provider "aws" {
  region = "ap-south-1"
}

resource "aws_api_gateway_rest_api" "api" {
  name = "assignment-api"
}

# =============================
# ROUTE 1 - /weather
# =============================

resource "aws_api_gateway_resource" "weather" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "weather"
}

resource "aws_api_gateway_method" "weather_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.weather.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "weather_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.weather.id
  http_method             = aws_api_gateway_method.weather_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"

  uri = "https://api.open-meteo.com/v1/forecast?latitude=12.97&longitude=77.59&current_weather=true"
}

# =============================
# ROUTE 2 - /countries/{name}
# =============================

resource "aws_api_gateway_resource" "countries" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "countries"
}

resource "aws_api_gateway_resource" "country_name" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.countries.id
  path_part   = "{name}"
}

resource "aws_api_gateway_method" "countries_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.country_name.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.name" = true
  }
}

resource "aws_api_gateway_integration" "countries_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.country_name.id
  http_method             = aws_api_gateway_method.countries_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"

  uri = "https://restcountries.com/v3.1/name/{name}"

  request_parameters = {
    "integration.request.path.name" = "method.request.path.name"
  }
}

# =============================
# ROUTE 3 - /json/{todo+}
# =============================

resource "aws_api_gateway_resource" "json" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "json"
}

resource "aws_api_gateway_resource" "todo_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.json.id
  path_part   = "{todo+}"
}

resource "aws_api_gateway_method" "json_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.todo_proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.todo" = true
  }
}

resource "aws_api_gateway_integration" "json_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.todo_proxy.id
  http_method             = aws_api_gateway_method.json_any.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"

  uri = "https://jsonplaceholder.typicode.com/{todo}"

  request_parameters = {
    "integration.request.path.todo" = "method.request.path.todo"
  }
}

# =============================
# DEPLOYMENT + STAGE
# =============================

resource "aws_api_gateway_deployment" "deployment" {

  depends_on = [
    aws_api_gateway_integration.weather_integration,
    aws_api_gateway_integration.countries_integration,
    aws_api_gateway_integration.json_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.weather_integration.id,
      aws_api_gateway_integration.countries_integration.id,
      aws_api_gateway_integration.json_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = "v1"
}