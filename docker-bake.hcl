group "default" {
  targets = ["mainnet", "testnet", "devnet"]
}

group "minimal" {
  targets = ["mainnet", "testnet", "devnet"]
}

variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}

variable "UPSTREAM_REF" {
  default = "v3.0.1"
}

variable "TESTNET_REF" {
  default = "v3.0.1-testnet"
}

variable "ORG" {
  default = "iosh"
}

variable "IMAGE_NAME" {
  default = "conflux-node"
}

variable "PUSH" {
  default = "false"
}

target "_base" {
  dockerfile = "docker/runtime/Dockerfile.minimal"
  context    = "."
  platforms  = split(",", PLATFORMS)
  args = {
    UPSTREAM_REF = UPSTREAM_REF
  }
  output = ["type=image,push=${PUSH}"]
  labels = {
    "org.opencontainers.image.vendor"     = "${ORG}"
    "org.opencontainers.image.authors"    = "https://github.com/${ORG}"
    "org.opencontainers.image.source"     = "https://github.com/Conflux-Chain/conflux-rust"
    "org.opencontainers.image.licenses"   = "GPL-3.0"
    "org.opencontainers.image.created"    = timestamp()
    "org.opencontainers.image.version"    = "${UPSTREAM_REF}"
  }
}

target "_minimal" {
  inherits = ["_base"]
}

target "mainnet" {
  inherits = ["_minimal"]
  args = {
    NETWORK = "mainnet"
  }
  tags = ["ghcr.io/${ORG}/${IMAGE_NAME}:${UPSTREAM_REF}-mainnet"]
  labels = {
    "org.opencontainers.image.title"       = "Conflux Node (mainnet)"
    "org.opencontainers.image.description" = "A Docker image for Conflux mainnet node."
  }
}

target "testnet" {
  inherits = ["_minimal"]
  args = {
    NETWORK = "testnet"
    UPSTREAM_REF = TESTNET_REF
  }
  tags = ["ghcr.io/${ORG}/${IMAGE_NAME}:${TESTNET_REF}-testnet"]
  labels = {
    "org.opencontainers.image.title"       = "Conflux Node (testnet)"
    "org.opencontainers.image.description" = "A Docker image for Conflux testnet node."
    "org.opencontainers.image.version"     = "${TESTNET_REF}"
  }
}

target "devnet" {
  inherits = ["_minimal"]
  args = {
    NETWORK = "devnet"
  }
  tags = ["ghcr.io/${ORG}/${IMAGE_NAME}:${UPSTREAM_REF}-devnet"]
  labels = {
    "org.opencontainers.image.title"       = "Conflux Node (devnet)"
    "org.opencontainers.image.description" = "A Docker image for Conflux devnet node."
  }
}