#!/bin/bash
# AutoBuild Module by Hyy2001X <https://github.com/Hyy2001X/AutoBuild-Actions-BETA>
# AutoBuild DiyScript

Firmware_Diy_Core() {

	# 请在此处填写自定义设置, 使用 case 语句可以针对不同源码设置不同的自定义设置
	# 可用变量
	# ${OP_AUTHOR}		OpenWrt 源码作者: !
	# ${OP_REPO}		OpenWrt 仓库路径
	# ${OP_BRANCH}		OpenWrt 源码分支
	# ${CONFIG_FILE}	配置文件

	Author="OpenWrt"
	# 固件作者, AUTO: [默认值]

	Author_URL="AUTO"
	# 作者的自定义网站, AUTO: [默认值]

	Default_Flag="GHL-R-001"
	# 固件标签 (可留空), 如需使用请填写自定义标签, AUTO: [默认值]

	Default_IP="192.168.6.1"
	# 固件 IP 地址

	Default_Title="OpenWrt"
	# 浏览器标签页显示的标题

	Short_Fw_Date=true
	# 简短的固件日期, true: [20210601]; false: [202106012359]

	x86_Full_Images=false
	# 是否构建包含所有镜像的 x86 固件压缩包, true: [构建]; false: [不构建]

	Fw_MFormat=AUTO
	# 自定义固件格式, AUTO: [默认值]

	Regexp_Skip="packages|buildinfo|sha256sums|manifest|kernel|rootfs|factory|itb|profile|ext4|json"
	# 不需要重命名的固件后缀/文件

	AutoBuild_Features=true
	# 启用 AutoBuild 固件功能, true: [启用]; false: [禁用]

	AutoBuild_Features_Patch=false
	AutoBuild_Features_Kconfig=false
}

Firmware_Diy() {

	# 请在此处填写自定义设置

	# 可用变量
	# ${OP_AUTHOR}		OpenWrt 源码作者: !
	# ${OP_REPO}		OpenWrt 仓库路径
	# ${OP_BRANCH}		OpenWrt 源码分支
	# ${TARGET_PROFILE}	目标配置
	# ${TARGET_BOARD}	目标架构
	# ${TARGET_FLAG}	固件标签
	# ${CONFIG_FILE}	配置文件

	# ${CustomFiles}	仓库中的 /CustomFiles 目录路径
	# ${Scripts}		仓库中的 /Scripts 目录路径

	# ${WORK}		OpenWrt 源码根目录
	# ${FEEDS_CONF}		OpenWrt 源码中的 feeds.conf.default 文件
	# ${FEEDS_LUCI}		OpenWrt 源码中的 package/feeds/luci 路径
	# ${FEEDS_PKG}		OpenWrt 源码中的 package/feeds/packages 路径
	# ${BASE_FILES}		OpenWrt 源码中的 package/base-files/files 路径

	# AddPackage <package_path> <git_user> <git_repo> <git_branch>
	# ClashDL <platform> <core_type> [dev/tun/meta]
	# ReleaseDL <release_url> <file> <target_path>
	# Copy <cp_from> <cp_to > <rename>
	# merge_package <git_branch> <git_repo_url> <package_path> <target_path>..

	case "${OP_AUTHOR}/${OP_REPO}:${OP_BRANCH}" in
	coolsnowwolf/lede:master)

		sed -i '/check_signature/d' etc/opkg.conf

		sed -i 's|downloads.openwrt.org|mirrors.tuna.tsinghua.edu.cn/openwrt|g' etc/opkg/customfeeds.conf
		sed -i 's|downloads.openwrt.org|mirrors.tuna.tsinghua.edu.cn/openwrt|g' etc/opkg/distfeeds.conf

		sed -i "s/hostname='OpenWrt'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate
		sed -i "s|option hostname.*|option hostname 'OpenWrt'|g" package/base-files/files/bin/config_generate

		sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

		sed -i 's|option type dns|option type dns\n\toption noresolv 1|g' package/network/services/dnsmasq/files/dhcp.conf

		sed -i '/customized by OpenClash/d' package/lean/default-settings/files/zzz-default-settings
		sed -i '/option cpuinfo_arm/d' package/lean/default-settings/files/zzz-default-settings

		sed -i 's|option http_port 80|option http_port 80\n\toption redirect_https 0|g' feeds/luci/modules/luci-base/root/etc/config/uhttpd

		sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

		AddPackage themes jerrykuku luci-theme-argon 18.06
		AddPackage other jerrykuku luci-app-argon-config master

		case "${TARGET_BOARD}" in
		ramips)
			sed -i "/DEVICE_COMPAT_VERSION := 1.1/d" target/linux/ramips/image/mt7621.mk

			sed -i "s/set luci.main.mediaurlbase=\/luci-static\/bootstrap/set luci.main.mediaurlbase=\/luci-static\/argon/g" package/default-settings/files/zzz-default-settings 2>/dev/null || true

			echo 'config defaults\n\toption input\t\tACCEPT\n\toption output\t\tACCEPT\n\toption forward\t\tREJECT\n\toption syn_flood\t1\n\toption flow_offloading\t1\n\toption flow_offloading_hw\t1' > package/network/config/firewall/files/firewall.config
			;;
		esac
		;;
	esac
}
