#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="raine"
rp_module_desc="Raine Emulator"
rp_module_help="ROM Extensions: .zip .7z\n\nCopy your raine roms to $romdir/raine\nCopy your emudx files to $romdir/raine/emudx"
rp_module_licence="Source-available https://raw.githubusercontent.com/zelurker/raine/refs/heads/master/source/Musashi/readme.txt"
rp_module_repo="git https://github.com/zelurker/raine.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_raine() {
    # Install required libraries required for compilation and running
    local depends=(nasm liblua5.4-dev libcurl4-gnutls-dev libssl-dev libpng-dev)
	getDepends "${depends[@]}"
	# libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev needed but not installed by the script yet, use RetroPie-Setup or your own method
}

function sources_raine() {
    gitPullOrClone
    patch -N $md_build/makefile < "$md_data/makefile.diff"
    patch -N $md_build/source/sdl/sasound.c < "$md_data/sasound.diff"
}

function build_raine() {
    # More memory is required for 64bit platforms
    if isPlatform "64bit"; then
        rpSwap on 4096
    else
        rpSwap on 2048
    fi

    make

    rpSwap off
    md_ret_require="$md_build/raine"
}

function install_raine() {
    md_ret_files=(
        'raine'
    )
}

function configure_raine() {
    local system="raine"

    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "$system"
        
        # Create required RAINE directories underneath the ROM directory
        local raine_sub_dir
        for raine_sub_dir in artwork emudx screens; do
            mkRomDir "$system/$raine_sub_dir"
        done
        
        # Create required RAINE config directories underneath the config directory
        local raine_config_sub_dir
        for raine_config_sub_dir in config debug demos fonts ips savedata savegame; do
            mkUserDir "$md_conf_root/$system/$raine_config_sub_dir"
        done
	
        # Create the configuration directory for the raine config files
        moveConfigDir "/home/$user/.raine" "$md_conf_root/$system"
        
        # Move fonts to the config directory
        cp -f -r "$md_build/fonts" "$md_conf_root/$system"
        # Copy the config file to the config directory
        cp -f "$md_data/rainex_sdl.cfg" "$md_conf_root/$system/config/rainex_sdl.cfg"
        # Ensure the correct username is used in the paths, within the config file
        sed -i "s/\~/\/pi\/\/$user\//g" "$md_conf_root/$system/config/rainex_sdl.cfg"
        # Ensure the correct user rights for all files in the config directory
        chown $user:$user -R "$md_conf_root/$system"
	fi
	
    addEmulator 0 "$md_id" "$system" "$md_inst/raine %BASENAME%"
    # Force name and extensions to be added to the es_systems.cfg as raine is not part of the platforms.cfg
    addSystem "$system" "$md_desc" ".zip .7z"
}
