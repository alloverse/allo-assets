import bpy
import sys
argv = sys.argv
argv = argv[argv.index("--") + 1:]  # get all args after "--"

# from addon_utils import check, enable
# bpy.ops.wm.read_factory_settings(use_empty=True)
# for addon in ("io_export_dxf", "io_scene_gltf2", "io_mesh_stl", "io_mesh_3mf"):
#     default, enabled = check(addon)
#     if not enabled:
#         enable(addon, default_set=True, persistent=True)

fin = argv[0]
fout = argv[1]
# bpy.ops.wm.read_factory_settings(use_empty=True)
# bpy.ops.import_mesh.stl(filepath=fin)
bpy.ops.import_mesh.threemf(filepath=fin)
bpy.ops.export_scene.gltf(filepath=fout)