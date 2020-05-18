macro(GroupSources dir)
    file(GLOB_RECURSE elements RELATIVE ${dir} *.h *.hpp *.c *.cpp *.cc)

    foreach(element ${elements})
      get_filename_component(element_name ${element} NAME)
      get_filename_component(element_dir ${element} DIRECTORY)

      if (NOT ${element_dir} STREQUAL "")
          string(REPLACE "/" "\\" group_name ${element_dir})
          source_group("${group_name}" FILES ${dir}/${element})
      else()
        source_group("\\" FILES ${dir}/${element})
      endif()
    endforeach()
endmacro()