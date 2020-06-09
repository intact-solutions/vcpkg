include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hypre-space/hypre
    REF v2.11.2
    SHA512 bff1ccae79294ebfee3611107df2aede9837838a71d607d6e8aab91658f83fee5d8d6a306facc54e9d0e3591dd634dc3742e52104bdbb23ae98475f3c5191ad3
    PATCHES
        fix-root-cmakelists.patch
        fix-macro-to-template.patch
        fix-blas-vs14-math.patch
        fix-lapack-vs14-math.patch
        fix-export-global-data-symbols.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(OPTIONS -DHYPRE_SHARED=ON)
else()
  set(OPTIONS -DHYPRE_SHARED=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
    OPTIONS_RELEASE
        -DHYPRE_BUILD_TYPE=Release
        -DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
    OPTIONS_DEBUG
        -DHYPRE_BUILD_TYPE=Debug
        -DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/hypre/copyright)
