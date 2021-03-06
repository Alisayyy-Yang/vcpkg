include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Alembic does not support static linkage. Building dynamically.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF 1.7.7
    SHA512 0ebcf6b9304e84bc60f1c146d0b5e5c5b1de43974ec0725293c444b48b22640945f5883eb9afd46c1ac9f0c260d6f22ff29b4866d6525c416339877be984b149
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/fix-hdf5link.patch
    ${CMAKE_CURRENT_LIST_DIR}/bypass-findhdf5.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DUSE_HDF5=ON
    -DHDF5_ROOT=${CURRENT_INSTALLED_DIR}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/Alembic")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/Alembic.dll ${CURRENT_PACKAGES_DIR}/bin/Alembic.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/Alembic.dll ${CURRENT_PACKAGES_DIR}/debug/bin/Alembic.dll)

file(READ ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-debug.cmake DEBUG_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}/debug/lib/Alembic.dll"
               "\${_IMPORT_PREFIX}/debug/bin/Alembic.dll" DEBUG_CONFIG "${DEBUG_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-debug.cmake "${DEBUG_CONFIG}")

file(READ ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-release.cmake RELEASE_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}/lib/Alembic.dll"
               "\${_IMPORT_PREFIX}/bin/Alembic.dll" RELEASE_CONFIG "${RELEASE_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-release.cmake "${RELEASE_CONFIG}")

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/Alembic/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/Alembic/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/Alembic/copyright)
