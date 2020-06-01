include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfem/mfem
    REF f8174fa8cd38b303933ad27dfc7d70b7f71c8c6f
    SHA512 6792338f9f1c48fdffa1ab08d9361d7cd7fabc822b818e1c3b5b9218623c790d3c289526f7b910f985ce3e553804f62a383232ebbebc68a2777091f072237325
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
        -DMFEM_MPI=ON
        -DMETIS_DIR=${CURRENT_INSTALLED}
        -DHYPRE_DIR=${CURRENT_INSTALLED}
)


vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mfem)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mfem)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mfem/LICENSE ${CURRENT_PACKAGES_DIR}/share/mfem/copyright)
