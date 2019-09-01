# Initial installer

include $(TOPDIR)/rules.mk

PKG_NAME:=firstinstall
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/firstinstall
  SECTION:=vent
  CATEGORY:=VisibleEnergyNTOP
  TITLE:=Tool to automate first eMMC installation
  MAINTAINER:=James Smith <jsmith@rallysmith.co.uk>
endef

define Package/firstinstall/description
 This package contains the utility script which can be used to setup
 the eMMC filesystems.
endef

# We only have a script at the moment so nothing to compile:
define Build/Compile
endef

define Package/firstinstall/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_BIN) ./files/firstinstall.sh $(1)/usr/bin/
	$(INSTALL_DATA) ./files/vent.layout $(1)/root
endef

$(eval $(call BuildPackage,firstinstall))
