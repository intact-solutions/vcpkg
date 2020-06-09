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
        -DMFEM_USE_MPI=YES
        -DMFEM_USE_METIS=1
        -DMETIS_DIR=${CURRENT_INSTALLED}
        -DHYPRE_DIR=${CURRENT_INSTALLED}
        -DMFEM_THREAD_SAFE=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
# We cannot use vcpkg_fixup_cmake_targets, though that would be ideal
# https://github.com/Microsoft/vcpkg/issues/6113
# https://github.com/microsoft/vcpkg/pull/7524
# vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mfem)
# Instead we have to move things manually
# and accept that we can't support debug builds
set(CMAKE_FILE_NAMES "MFEMConfig.cmake;MFEMConfigVersion.cmake;MFEMTargets-release.cmake;MFEMTargets.cmake")
foreach(CMAKE_FILE_NAME IN LISTS CMAKE_FILE_NAMES)
    set(CMAKE_FILE_PATH "${CURRENT_PACKAGES_DIR}/share/mfem/${CMAKE_FILE_NAME}")

    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/mfem/${CMAKE_FILE_NAME}" "${CMAKE_FILE_PATH}")
    # We also need to update the install directory, something that would have been taken care of fixup_targets
    file(READ "${CMAKE_FILE_PATH}" _contents)
    string(REGEX REPLACE
        "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
        "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
        _contents "${_contents}") # see #1044 for details why this replacement is necessary. See #4782 why it must be a regex.
    string(REGEX REPLACE
        "get_filename_component\\(PACKAGE_PREFIX_DIR \"\\\${CMAKE_CURRENT_LIST_DIR}/\\.\\./(\\.\\./)*\" ABSOLUTE\\)"
        "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)"
        _contents "${_contents}")
    file(WRITE "${CMAKE_FILE_PATH}" "${_contents}")
endforeach()

# We've moved all the cmake files here anyhow
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")

# These directories are duplicated in debug, so we remove them
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/mfem" RENAME copyright)