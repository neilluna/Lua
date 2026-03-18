cmake_minimum_required(VERSION 3.20)
project(lua C)

set(LUA_SRC_DIR "${CMAKE_SOURCE_DIR}/src")

# Lua 5.1.5 core + standard libraries (static)
add_library(lua51 STATIC
  ${LUA_SRC_DIR}/lapi.c
  ${LUA_SRC_DIR}/lcode.c
  ${LUA_SRC_DIR}/ldebug.c
  ${LUA_SRC_DIR}/ldo.c
  ${LUA_SRC_DIR}/ldump.c
  ${LUA_SRC_DIR}/lfunc.c
  ${LUA_SRC_DIR}/lgc.c
  ${LUA_SRC_DIR}/llex.c
  ${LUA_SRC_DIR}/lmem.c
  ${LUA_SRC_DIR}/lobject.c
  ${LUA_SRC_DIR}/lopcodes.c
  ${LUA_SRC_DIR}/lparser.c
  ${LUA_SRC_DIR}/lstate.c
  ${LUA_SRC_DIR}/lstring.c
  ${LUA_SRC_DIR}/ltable.c
  ${LUA_SRC_DIR}/ltm.c
  ${LUA_SRC_DIR}/lundump.c
  ${LUA_SRC_DIR}/lvm.c
  ${LUA_SRC_DIR}/lzio.c

  ${LUA_SRC_DIR}/lauxlib.c
  ${LUA_SRC_DIR}/lbaselib.c
  ${LUA_SRC_DIR}/ldblib.c
  ${LUA_SRC_DIR}/liolib.c
  ${LUA_SRC_DIR}/lmathlib.c
  ${LUA_SRC_DIR}/loadlib.c
  ${LUA_SRC_DIR}/loslib.c
  ${LUA_SRC_DIR}/lstrlib.c
  ${LUA_SRC_DIR}/ltablib.c
  ${LUA_SRC_DIR}/linit.c
)

target_include_directories(lua51 PUBLIC ${LUA_SRC_DIR})

# Optional: quiet MSVC "unsafe CRT" warnings
target_compile_definitions(lua51 PRIVATE _CRT_SECURE_NO_WARNINGS)

# Put outputs in build\<Config>\
set_target_properties(lua51 PROPERTIES
  OUTPUT_NAME "lua51"
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>"
)

# lua.exe
add_executable(lua ${LUA_SRC_DIR}/lua.c)
target_link_libraries(lua PRIVATE lua51)
target_compile_definitions(lua PRIVATE _CRT_SECURE_NO_WARNINGS)
set_target_properties(lua PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>"
)

# luac.exe (Lua 5.1.x uses print.c)
add_executable(luac
  ${LUA_SRC_DIR}/luac.c
  ${LUA_SRC_DIR}/print.c
)
target_link_libraries(luac PRIVATE lua51)
target_compile_definitions(luac PRIVATE _CRT_SECURE_NO_WARNINGS)
set_target_properties(luac PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>"
)
