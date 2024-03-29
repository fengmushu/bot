#
# Copyright (C) 2011-2012 Tenbay <ken@tt-cool.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bot
PKG_VERSION:=0.2
PKG_RELEASE:=1
PKG_LICNESE:=GPL-2.0+

include $(INCLUDE_DIR)/package.mk

define Package/bot
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Test Bot base on iperf2 or iperf3
  DEPENDS:=+iperf +iperf3
  MAINTAINER:=Tenbay <ken@tt-cool.com>
endef

define Package/bot/description
	Configure based test bot client for throughput
endef

define Build/Configure
endef

TARGET_LDFLAGS +=

define Build/Compile
endef

define Package/bot/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bot.init $(1)/etc/init.d/98_bot
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bot.default $(1)/etc/uci-defaults/99_bot
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/bot.hotplug.iface.sh $(1)/etc/hotplug.d/iface/80_bot
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bot.sh $(1)/usr/sbin/bot
endef

$(eval $(call BuildPackage,bot))
