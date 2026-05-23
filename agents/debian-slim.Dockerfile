FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
	apt install -y \
		bash \
		curl \
		wget \
		iputils-ping \
		git
