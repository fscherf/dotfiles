FROM debian:forky-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
	apt install -y \
		bash \
		curl \
		wget \
		iputils-ping \
		git \
		# needed for pi (version in stable is to old) \
		nodejs \
		npm
