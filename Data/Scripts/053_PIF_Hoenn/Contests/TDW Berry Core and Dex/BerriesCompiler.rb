# #===============================================================================
# # Compiler
# #===============================================================================
# module Compiler
#   module_function
#
#   Compiler.singleton_class.send(:alias_method, :berry_core_comp_pbs, :compile_pbs_files)
#
#   def compile_pbs_files
#     berry_core_comp_pbs
#     compile_berry_data
#     compile_berry_dexes
#   end
#
#
#
# end