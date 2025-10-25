# Use the latest Ubuntu as the base image
FROM docker.io/ubuntu:25.10

# Set environment variables for the container
ENV LANG="C.UTF-8" \
	DEBIAN_FRONTEND="noninteractive" \
	DISPLAY_HEIGHT=1080 \
	DISPLAY_WIDTH=1920 \
	DISPLAY=:0.0 \
	HOME="/home/ubuntu" \
	LANG="C.UTF-8" \
	NO_COLOR=1 \
	NONINTERACTIVE=1 \
	PIP_DISABLE_PIP_VERSION_CHECK=1 \
	PIP_ROOT_USER_ACTION="ignore" \
	PYTHONUNBUFFERED="True" \
	RUN_FLUXBOX="True" \
	RUN_XTERM="False" \
	RUN_FIREFOX="False" \
	RUN_DOOM="False"

# Update the package list and install necessary packages
RUN set -ex; \
	apt-get update -yq && \
	apt-get install -yqq \
		apt-transport-https \
		apt-utils \
		bash \
		build-essential \
		ca-certificates \
		chocolate-doom \
		curl \
		fluxbox \
		git \
		gpg \
		htop \
		mousepad \
		net-tools \
		novnc \
		supervisor \
		x11vnc \
		xterm \
		xvfb \
		zip && \
	# Create index start autostart noVNC in Browser
	ln "/usr/share/novnc/vnc.html" "/usr/share/novnc/index.html" && \
	# Add the Mozilla repository to install the latest version of Firefox
	curl -fsSL "https://packages.mozilla.org/apt/repo-signing-key.gpg"| gpg --dearmor -o "/usr/share/keyrings/mozilla.gpg" && \
	echo "deb [signed-by=/usr/share/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main" | tee -a "/etc/apt/sources.list.d/mozilla.list" && \
	printf "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n\nPackage: firefox*\nPin: release o=Ubuntu\nPin-Priority: -1\n" | tee "/etc/apt/preferences.d/mozilla" && \
	apt-get update -yq && \
	apt-get install -yqq firefox && \
	# Delete caches
	echo "Clean up..." && \
	apt-get clean               && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*               && \
	# Delete all log file
	find /var/log -type f -delete && \
	# Set permissions
	chown -R ubuntu:ubuntu "$HOME" && \
	touch "/supervisord.log" "/supervisord.pid" && \
	chown ubuntu:ubuntu "/supervisord.log" "/supervisord.pid"

# Copy the application configuration files
COPY --chown=ubuntu:ubuntu . /app

# Create a directory for Firefox policies and move the policies.json file
# More to read: https://mozilla.github.io/policy-templates/
RUN mkdir -p "/usr/lib/firefox/distribution" && \
	mv "/app/conf.d/firefox/policies.json" "/usr/lib/firefox/distribution/" && \
	chown root:root "/usr/lib/firefox/distribution/policies.json"

# Switch to the non-root user
USER ubuntu

# Create the Fluxbox configuration directory and link the menu file
RUN mkdir -p "$HOME/.fluxbox" && \
	ln -s "/app/conf.d/fluxbox-menu" "$HOME/.fluxbox/menu"

# Set the entrypoint
CMD ["/app/entrypoint.sh"]

# Expose the port for the noVNC server
EXPOSE 8080