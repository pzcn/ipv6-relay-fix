include $(TOPDIR)/rules.mk

PKG_NAME:=ipv6-relay-fix
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Your Name <your.email@example.com>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/ipv6-relay-fix
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IPv6
  TITLE:=IPv6 Relay Mode Configuration Fix
  DESCRIPTION:=Fixes IPv6 relay mode configuration issues in OpenWrt, \
    including route table problems and learning route conflicts.
  DEPENDS:=+odhcpd +kmod-ipv6 +ip6tables
  PKGARCH:=all
endef

define Package/ipv6-relay-fix/description
  This package provides automatic configuration and fixes for IPv6 relay mode
  in OpenWrt routers. It solves common issues including:
  - Automatic IPv6 relay mode configuration
  - Route table correction for downstream devices
  - Disabling conflicting learning routes
  - Hotplug-based route maintenance
endef

define Package/ipv6-relay-fix/conffiles
/etc/config/ipv6-relay-fix
endef

define Build/Compile
	# Nothing to compile for shell scripts
endef

define Package/ipv6-relay-fix/install
	# Install UCI defaults script
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-ipv6-relay-config $(1)/etc/uci-defaults/
	
	# Install hotplug script
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/99-ipv6-route-fix $(1)/etc/hotplug.d/iface/
	
	# Install init script
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ipv6-relay-fix.init $(1)/etc/init.d/ipv6-relay-fix
	
	# Install default config
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ipv6-relay-fix.config $(1)/etc/config/ipv6-relay-fix
endef

define Package/ipv6-relay-fix/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	echo "Configuring IPv6 relay mode..."
	/etc/init.d/ipv6-relay-fix enable
	uci-defaults
}
exit 0
endef

define Package/ipv6-relay-fix/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/ipv6-relay-fix stop
	/etc/init.d/ipv6-relay-fix disable
}
exit 0
endef

$(eval $(call BuildPackage,ipv6-relay-fix))
